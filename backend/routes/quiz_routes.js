import express from "express";
import {
  generateMcq,
  publishQuiz,
  searchQuiz,
  createAttempt,
  getQuestion,
  saveAnswer,
  submitQuiz,
  userStats,
  teacherStats,
  leaderboard
} from "../controller/quiz_controller.js";
import { generateMcqLimiter } from "../middleware/ratelimiter.js";
import { verifyToken } from "../middleware/auth.js";
import upload from "../middleware/upload.js";
import rateLimit from "express-rate-limit";

const QuizRouter = express.Router();

QuizRouter.post("/generate-mcq", verifyToken, generateMcqLimiter, upload.single("file"), generateMcq);
QuizRouter.post("/publish-quiz", verifyToken, publishQuiz);
QuizRouter.post("/search-quiz",  verifyToken, searchQuiz);
QuizRouter.post("/create-attempt", verifyToken, createAttempt);
QuizRouter.post("/get-question",   verifyToken, getQuestion);
QuizRouter.post("/save-answer",    verifyToken, saveAnswer);
QuizRouter.post("/submit-quiz",    verifyToken, submitQuiz);
QuizRouter.get("/user-stats",    verifyToken, userStats);
QuizRouter.get("/teacher-stats",verifyToken,teacherStats);
QuizRouter.get("/leaderboard",verifyToken,leaderboard);
export default QuizRouter;