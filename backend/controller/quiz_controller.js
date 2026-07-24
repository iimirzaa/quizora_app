import fs from "fs";
import mammoth from "mammoth";
import jwt from 'jsonwebtoken';
import Groq from "groq-sdk";
import * as pdfjsLib from "pdfjs-dist/legacy/build/pdf.mjs";
import { auth, db, FieldValue } from "../firebase/firebase_admin.js";

export const generateMcq = async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ success: false, message: "No file uploaded" });
  }

  const filePath = req.file.path;

  try {
    // 1. extract text
    let text = "";

    if (req.file.mimetype === "application/pdf") {
      const buffer = fs.readFileSync(filePath);
      const uint8Array = new Uint8Array(buffer);
      const pdf = await pdfjsLib.getDocument({ data: uint8Array }).promise;

      for (let i = 1; i <= pdf.numPages; i++) {
        const page = await pdf.getPage(i);
        const content = await page.getTextContent();
        text += content.items.map(item => item.str).join(" ") + "\n";
      }

    } else {
      const result = await mammoth.extractRawText({ path: filePath });
      text = result.value;
    }

    if (!text || text.trim().length < 100) {
      return res.status(400).json({ success: false, message: "Not enough text in file" });
    }

    console.log(text);
    // with this
    const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });


    const numQuestions = req.body.numQuestions || 5;
    const difficulty = req.body.difficulty || "medium";

    const prompt = `Generate ${numQuestions} MCQs from the text below at ${difficulty} difficulty.
Return ONLY a JSON array, no markdown, no extra text.
Each item:
{
  "question": "string",
  "options": [{label:"A",text=".............."}],
  "answer": "A" or "B" or "C" or "D",
  "explanation": "one sentence"
}
Text: ${text.substring(0, 6000)}`;

    const completion = await groq.chat.completions.create({
      model: "llama-3.3-70b-versatile",
      messages: [{ role: "user", content: prompt }],
    });
    const raw = completion.choices[0].message.content
      .replace(/```json|```/g, "")
      .trim();
    console.log(raw);

    const mcqs = JSON.parse(raw); // ← this line was missing

    return res.status(200).json({ success: true, message: "Mcq created", total: mcqs.length, mcqs });



  } catch (err) {
    console.error("MCQ error:", err);
    return res.status(500).json({ success: false, message: err.message || "Server error" });

  } finally {
    if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
  }
};


const generateQuizCode = () =>
  Math.random().toString(36).substring(2, 8).toUpperCase();

export const publishQuiz = async (req, res) => {
  try {
    const { title, mcqs, duration } = req.body;

    // extract userId from token
    const token = req.headers.authorization?.split(" ")[1];
    if (!token) {
      return res.status(401).json({ success: false, message: "No token provided" });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const userId = decoded.id; // whatever field you stored on login

    console.log("userId:", userId);
    console.log("title:", title);
    console.log("mcqs count:", mcqs?.length);

    // validate
    if (!title || !duration || !mcqs || mcqs.length === 0) {
      return res.status(400).json({ success: false, message: "Missing required fields" });
    }

    const quizCode = generateQuizCode();
    const quizRef = db.collection("quizzess").doc();

    // save quiz
    await quizRef.set({
      title,
      duration: Number(duration),
      quizCode,
      createdBy: userId,
      isActive: true,
      totalAttempts: 0,
      mcqs, // [{ question, options, answer, explanation }]
      createdAt: new Date(Date.now()),
    });
    // in publishQuiz, after quizRef.set(...)
    const teacherStatsRef = db.collection("teacherStats").doc(userId);
    const teacherStatsDoc = await teacherStatsRef.get();

    if (!teacherStatsDoc.exists) {
      await teacherStatsRef.set({
        totalQuizzesCreated: 1,
        quizzes: [{ quizId: quizRef.id, title, createdAt: new Date() }],
      });
    } else {
      await teacherStatsRef.update({
        totalQuizzesCreated: FieldValue.increment(1),
        quizzes: FieldValue.arrayUnion({ quizId: quizRef.id, title, createdAt: new Date(), }),
      });
    }
    // initialize stats
    await quizRef.collection("stats").doc("summary").set({
      totalAttempts: 0,
      highestScore: 0,
      lowestScore: 100,
      averageScore: 0,
      passCount: 0,
      failCount: 0,
      lastAttemptAt: null,
    });

    return res.status(201).json({
      success: true,
      message: "Quiz published successfully",
      quizId: quizRef.id,
      quizCode,
    });

  } catch (err) {
    console.error("Publish quiz error:", err.message);

    if (err.name === "JsonWebTokenError" || err.name === "TokenExpiredError") {
      return res.status(401).json({ success: false, message: "Invalid or expired token" });
    }

    return res.status(500).json({ success: false, message: err.message });
  }
};


// controller — token already verified, just use req.user
export const searchQuiz = async (req, res) => {
  try {
    const { code } = req.body;

    if (!code) {
      return res.status(400).json({ success: false, message: "Quiz code is required" });
    }

    const snapshot = await db.collection("quizzess")
      .where("quizCode", "==", code.toUpperCase().trim())
      .limit(1)
      .get();

    if (snapshot.empty) {
      return res.status(404).json({ success: false, message: "Quiz not found" });
    }

    const doc = snapshot.docs[0];
    const quiz = doc.data();

    if (!quiz.isActive) {
      return res.status(403).json({ success: false, message: "Quiz is no longer active" });
    }



    return res.status(200).json({
      success: true,
      data: {
        quizId: doc.id,
        title: quiz.title,
        duration: quiz.duration,
        totalQuestions: quiz.mcqs.length,

      },
    });

  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: err.message });
  }
};
// ── create-attempt ────────────────────────────────────────
export const createAttempt = async (req, res) => {
  try {
    const { quizId } = req.body;
    const token = req.headers.authorization?.split(" ")[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const userId = decoded.id;

    if (!quizId) {
      return res.status(400).json({ success: false, message: "quizId is required" });
    }

    // check quiz exists and is active
    const quizDoc = await db.collection("quizzess").doc(quizId).get();
    if (!quizDoc.exists) {
      return res.status(404).json({ success: false, message: "Quiz not found" });
    }
    if (!quizDoc.data().isActive) {
      return res.status(403).json({ success: false, message: "Quiz is no longer active" });
    }

    // create attempt record
    const attemptRef = db.collection("quizzess").doc(quizId).collection("attempts").doc();
    await attemptRef.set({
      userId,
      status: "in_progress",
      answers: [],
      score: null,
      percentage: null,
      startedAt: new Date(),
      submittedAt: null,
    });

    return res.status(201).json({
      success: true,
      attemptId: attemptRef.id,
    });

  } catch (err) {
    console.error("Create attempt error:", err.message);
    if (err.name === "JsonWebTokenError" || err.name === "TokenExpiredError") {
      return res.status(401).json({ success: false, message: "Invalid or expired token" });
    }
    return res.status(500).json({ success: false, message: err.message });
  }
};


// ── get-question ──────────────────────────────────────────
export const getQuestion = async (req, res) => {
  try {
    const { quizId, index } = req.body;

    if (!quizId || index === undefined) {
      return res.status(400).json({ success: false, message: "quizId and index are required" });
    }

    const quizDoc = await db.collection("quizzess").doc(quizId).get();
    if (!quizDoc.exists) {
      return res.status(404).json({ success: false, message: "Quiz not found" });
    }

    const mcqs = quizDoc.data().mcqs;
    const total = mcqs.length;

    if (index >= total) {
      return res.status(200).json({ success: true, done: true, total });
    }

    // strip answer and explanation — never send to client
    const { question, options } = mcqs[index];

    return res.status(200).json({
      success: true,
      done: false,
      index,
      total,
      question: { question, options },
    });

  } catch (err) {
    console.error("Get question error:", err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
};


// ── save-answer ───────────────────────────────────────────
export const saveAnswer = async (req, res) => {
  try {
    const { quizId, attemptId, questionIndex, selectedIndex } = req.body;

    if (!quizId || !attemptId || questionIndex === undefined) {
      return res.status(400).json({ success: false, message: "quizId, attemptId and questionIndex are required" });
    }

    const attemptRef = db.collection("quizzess").doc(quizId)
      .collection("attempts").doc(attemptId);

    const attemptDoc = await attemptRef.get();
    if (!attemptDoc.exists) {
      return res.status(404).json({ success: false, message: "Attempt not found" });
    }
    if (attemptDoc.data().status !== "in_progress") {
      return res.status(403).json({ success: false, message: "Attempt already submitted" });
    }

    // save answer at correct index — upsert style
    const answers = attemptDoc.data().answers || [];
    answers[questionIndex] = selectedIndex ?? null;

    await attemptRef.update({ answers });

    return res.status(200).json({ success: true });

  } catch (err) {
    console.error("Save answer error:", err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
};


// ── submit-quiz ───────────────────────────────────────────
export const submitQuiz = async (req, res) => {
  try {
    const { quizId, attemptId, answers } = req.body;
    const token = req.headers.authorization?.split(" ")[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const userId = decoded.id;

    if (!quizId || !attemptId || !answers) {
      return res.status(400).json({ success: false, message: "quizId, attemptId and answers are required" });
    }

    const attemptRef = db.collection("quizzess").doc(quizId)
      .collection("attempts").doc(attemptId);

    const attemptDoc = await attemptRef.get();
    if (!attemptDoc.exists) {
      return res.status(404).json({ success: false, message: "Attempt not found" });
    }

    // idempotent — already submitted, return existing result
    if (attemptDoc.data().status === "submitted") {
      const d = attemptDoc.data();
      return res.status(200).json({
        success: true,
        score: d.score,
        percentage: d.percentage,
        total: d.total,
        breakdown: d.breakdown,
      });
    }

    const quizDoc = await db.collection("quizzess").doc(quizId).get();
    const mcqs = quizDoc.data().mcqs;
    const teacherId = quizDoc.data().createdBy;

    // score server-side
    let score = 0;
    const breakdown = mcqs.map((q, i) => {
      const correctIndex = q.options.findIndex(o => o.label === q.answer);
      const isCorrect = answers[i] === correctIndex;
      if (isCorrect) score++;
      return {
        question: q.question,
        options: q.options,
        selected: answers[i] ?? null,
        correctIndex,
        isCorrect,
        explanation: q.explanation,
      };
    });

    const percentage = Math.round((score / mcqs.length) * 100);

    // update attempt
    await attemptRef.update({
      status: "submitted",
      answers,
      score,
      percentage,
      total: mcqs.length,
      breakdown,
      submittedAt: new Date(),
    });


    await db.runTransaction(async (t) => {
      const statsRef = db.collection("quizzess").doc(quizId)
        .collection("stats").doc("summary");
      const userStatsRef = db.collection("userStats").doc(userId);
      const leaderboardRef = db.collection("leaderboard").doc(quizId).collection("entries").doc(userId);

      const teacherStatsRef = db.collection("teacherStats").doc(teacherId);
      // 1. READ EVERYTHING FIRST
      const statsSnap = await t.get(statsRef);
      const userStatsSnap = await t.get(userStatsRef);
      const teacherStatsSnap = await t.get(teacherStatsRef)


      const stats = statsSnap.data() || {
        totalAttempts: 0,
        averageScore: 0,
        highestScore: 0,
        lowestScore: 100,
        passCount: 0,
        failCount: 0,
      };
      const teacherStatsData = teacherStatsSnap.data() || {};

const teacherStats = {
  quizzes: teacherStatsData.quizzes ?? [],
  totalQuizzesCreated: teacherStatsData.totalQuizzesCreated ?? 0,
  totalAttempts: teacherStatsData.totalAttempts ?? 0,
  avgScore: teacherStatsData.avgScore ?? 0,
  passRate: teacherStatsData.passRate ?? 0,
  passedAttempts: teacherStatsData.passedAttempts ?? 0,
};
      
      console.log(teacherStats);

      const userStats = userStatsSnap.data() || {
        totalAttempted: 0,
        averageScore: 0,
        bestScore: 0,
        totalPassed: 0,
        recentAttempts: [],
      };

      // 2. COMPUTE ALL VALUES
      const newTotal = stats.totalAttempts + 1;
      const newAvg = Math.round(
        ((stats.averageScore * stats.totalAttempts) + percentage) / newTotal
      );
      const passCount = percentage >= 50 ? stats.passCount + 1 : stats.passCount;
      const newUserTotal = userStats.totalAttempted + 1;
      const newUserAvg = Math.round(
        ((userStats.averageScore * userStats.totalAttempted) + percentage) / newUserTotal
      );

      const recentAttempts = [
        { quizId, quizTitle: quizDoc.data().title, answers, attemptId, score, percentage, total: mcqs.length, breakdown, submittedAt: new Date() },
        ...userStats.recentAttempts,
      ].slice(0, 5);

      // 3. WRITE EVERYTHING LAST
      t.set(statsRef, {
        totalAttempts: newTotal,
        averageScore: newAvg,
        highestScore: Math.max(stats.highestScore, percentage),
        lowestScore: Math.min(stats.lowestScore, percentage),
        passCount: passCount,
        failCount: percentage < 50 ? stats.failCount + 1 : stats.failCount,
        lastAttemptAt: new Date(),
        uniqueStudents: FieldValue.increment(1),
      });

      t.set(leaderboardRef, {
        userId,
        score,
        percentage,
        submittedAt: new Date(),
      }, { merge: true });

      t.set(userStatsRef, {
        totalAttempted: newUserTotal,
        averageScore: newUserAvg,
        bestScore: Math.max(userStats.bestScore, percentage),
        totalPassed: percentage >= 50 ? userStats.totalPassed + 1 : userStats.totalPassed,
        recentAttempts,
      });
      const teacherTotalAttempts = teacherStats.totalAttempts + 1;

      const teacherPassedAttempts =
        percentage >= 50
          ? teacherStats.passedAttempts + 1
          : teacherStats.passedAttempts;

      const teacherAvgScore = Math.round(
        (
          teacherStats.avgScore * teacherStats.totalAttempts +
          percentage
        ) / teacherTotalAttempts
      );

      const teacherPassRate = Math.round(
        (teacherPassedAttempts / teacherTotalAttempts) * 100
      );
      console.log(teacherTotalAttempts);
      console.log(teacherAvgScore);
      
      t.set(
        teacherStatsRef,
        {
          totalAttempts: teacherTotalAttempts,
          avgScore: teacherAvgScore,
          passedAttempts: teacherPassedAttempts,
          passRate: teacherPassRate,
        },
        { merge: true }
      );
      return res.status(200).json({
        success: true,
        score,
        percentage,
        total: mcqs.length,
        breakdown,
      });
    });


  } catch (err) {
    console.error("Submit quiz error:", err);
    return res.status(500).json({ success: false, message: err.message });
  }
};
export const userStats = async (req, res) => {
  try {
    const token = req.headers.authorization?.split(" ")[1];
    if (!token) {
      return res.status(401).json({ success: false, message: "No token provided" });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const userId = decoded.id;

    const doc = await db.collection("userStats").doc(userId).get();

    if (!doc.exists) {
      return res.status(200).json({
        success: true,
        data: {
          totalAttempted: 0,
          averageScore: 0,
          bestScore: 0,
          totalPassed: 0,
          recentAttempts: [],
        },
      });
    }

    return res.status(200).json({
      success: true,
      data: doc.data(),
    });

  } catch (err) {
    console.error("User stats error:", err.message);
    if (err.name === "JsonWebTokenError" || err.name === "TokenExpiredError") {
      return res.status(401).json({ success: false, message: "Invalid or expired token" });
    }
    return res.status(500).json({ success: false, message: err.message });
  }
};
export const teacherStats = async (req, res) => {

  try {
    const token = req.headers.authorization?.split(" ")[1];
    if (!token) {
      return res.status(401).json({ success: false, message: "No token provided" });
    }
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const userId = decoded.id;

    const doc = await db.collection("teacherStats").doc(userId).get();

    if (!doc.exists) {
      return res.status(200).json({
        success: true,
        data: {
          totalQuizzesCreated: 0,
          quizzes: 0
        },
      });
    }

    return res.status(200).json({
      success: true,
      data: doc.data(),
    });

  } catch (err) {
    console.error("User stats error:", err.message);
    if (err.name === "JsonWebTokenError" || err.name === "TokenExpiredError") {
      return res.status(401).json({ success: false, message: "Invalid or expired token" });
    }
    return res.status(500).json({ success: false, message: err.message });
  }

}
export const leaderboard=(req,res)=>{
  try{
      const doc=db.collection('leaderboard').doc();

  }catch(e){

  }

}