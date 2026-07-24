import { v4 as uuid } from 'uuid';
import { auth, db, FieldValue } from "../firebase/firebase_admin.js";
import { hashPassword, verifyPassword } from '../providers/password_hashing.js';
import { generateAccessToken, generateRefreshToken } from '../providers/token_provider.js';
import { sendMail } from "../providers/mail_provider.js";
import { hashOtp } from '../providers/otp_hashing.js';
import { verifyUserOtp } from '../providers/otp_hashing.js';
import jwt from 'jsonwebtoken';


export const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // 1. Validate input
        if (!email || !password) {
            return res.status(400).json({ success: false, message: 'Email and password are required.' });
        }

        // 2. Search both collections in parallel
        const [studentSnap, teacherSnap] = await Promise.all([
            db.collection('students').where('email', '==', email).get(),
            db.collection('teachers').where('email', '==', email).get()
        ]);

        // 3. Determine which collection the user belongs to
        let userDoc, userData, role;

        if (!studentSnap.empty) {
            userDoc = studentSnap.docs[0];
            userData = userDoc.data();
            role = 'student';
        } else if (!teacherSnap.empty) {
            userDoc = teacherSnap.docs[0];
            userData = userDoc.data();
            role = 'teacher';
        } else {
            return res.status(404).json({ success: false, message: 'User not found.' });
        }

        // 4. Check if verified
        if (!userData.isVerified) {
            return res.status(403).json({ success: false, message: 'Please verify your email first.' });
        }

        // 5. Compare password

        const isValid = await verifyPassword(userData.hashedPassword, password);
        if (!isValid) {
            return res.status(401).json({ success: false, message: 'Invalid credentials.' });
        }

        // 6. Generate tokens with role in payload
        const payload = {
            id: userDoc.id,        // ✅ from doc reference not userData
            email: userData.email,
            role,                     // ✅ role included
        };

        const accessToken = await generateAccessToken(payload);
        const refreshToken = await generateRefreshToken(payload);

        // 7. Store refresh token in DB
        await userDoc.ref.update({ refreshToken });

        return res.status(200).json({
            success: true,
            message: 'Login Successful.',
            role: role,
            accessToken: accessToken,
            refreshToken: refreshToken,
        });

    } catch (e) {
        console.log(e);
        return res.status(500).json({ success: false, message: e.toString() });
    }
};

// ── Shared helper ────────────────────────────────────────────────────
async function buildOtpPayload(password) {
    const otp = Math.floor(100000 + Math.random() * 900000);
    const hashedPassword = await hashPassword(password);
    const hashedOtp = await hashOtp(otp.toString());
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);
    return { otp, hashedPassword, hashedOtp, expiresAt };
}

// ── Controller ───────────────────────────────────────────────────────
const VALID_ROLES = ['student', 'teacher'];

export const signUp = async (req, res) => {
    const { name, email, password, role } = req.body;

    // Role guard
    if (!VALID_ROLES.includes(role)) {
        return res.status(400).json({ success: false, message: 'Invalid role.' });
    }

    // Pick collection based on role
    const collection = role === 'teacher' ? 'teachers' : 'students';


    try {
        const snapshot = await db.collection(collection)
            .where('email', '==', email)
            .get();

        // ── Case 1: Email already exists ─────────────────────────────
        if (!snapshot.empty) {
            const userDoc = snapshot.docs[0];
            const userData = userDoc.data();

            if (userData.isVerified) {
                return res.status(409).json({
                    success: false,
                    message: 'An account with this email already exists.',
                });
            }

            // Unverified — resend OTP
            const { otp, hashedPassword, hashedOtp, expiresAt } =
                await buildOtpPayload(password);


            await userDoc.ref.update({
                name,
                hashedPassword,
                hashedOtp,
                expiresAt,
            });

            try {
                await sendMail(email, otp);
            } catch (mailErr) {
                return res.status(500).json({
                    success: false,
                    message: 'Failed to send OTP. Please try again.',
                });
            }

            return res.status(200).json({
                success: true,
                message: 'OTP resent. Please verify your email.',
            });
        }

        // ── Case 2: New user ──────────────────────────────────────────
        const { otp, hashedPassword, hashedOtp, expiresAt } =
            await buildOtpPayload(password);
        console.log(hashedPassword)

        const userRef = db.collection(collection).doc(uuid());

        // Base fields shared by both roles
        const baseData = {
            name,
            email,
            hashedPassword,
            role,
            isVerified: false,
            hashedOtp,
            expiresAt,
            createdAt: new Date().toISOString(),
        };

        // Role-specific extra fields
        const roleData = role === 'teacher'
            ? { createdQuizzes: [] }        // teacher extras
            : { enrolledQuizzes: [] };      // student extras

        await userRef.set({ ...baseData, ...roleData });

        try {
            await sendMail(email, otp);
        } catch (mailErr) {
            await userRef.delete();
            return res.status(500).json({
                success: false,
                message: 'Failed to send OTP. Please try again.',
            });
        }

        return res.status(201).json({
            success: true,
            message: 'SignUp successful. Please verify your email.',
        });

    } catch (e) {
        console.log(e);1
        return res.status(500).json({
            success: false,
            message: e.toString(),
        });
    }
};


export const verifyOtp = async (req, res) => {
    const { email, otp, role } = req.body;
    console.log(req.body)

    // Role guard
    if (!VALID_ROLES.includes(role)) {
        return res.status(400).json({ success: false, message: 'Invalid role.' });
    }

    const collection = role === 'teacher' ? 'teachers' : 'students';

    try {
        const snapshot = await db.collection(collection)
            .where('email', '==', email)
            .get();

        if (snapshot.empty) {
            return res.status(404).json({ success: false, message: 'User not found.' });
        }

        const userDoc = snapshot.docs[0];
        const userData = userDoc.data();

        if (userData.expiresAt.toDate() < new Date()) {
            return res.status(410).json({ success: false, message: 'OTP has expired.' });
        }

        if (!verifyUserOtp(userData.hashedOtp, otp)) {
            return res.status(400).json({ success: false, message: 'Invalid OTP.' });
        }

        await userDoc.ref.update({
            isVerified: true,
            hashedOtp: null,
            expiresAt: null,
        });

        return res.status(200).json({ success: true, message: 'OTP Verification Successful.' });

    } catch (e) {
        return res.status(500).json({ success: false, message: e.toString() });
    }
};
export const refreshToken = async (req, res) => {
    try {
        const { refresh_token } = req.body;

        // 1. Validate input
        if (!refresh_token) {
            return res.status(400).json({
                success: false,
                message: 'Refresh token is required.'
            });
        }

        // 2. Verify the refresh token signature + expiry
        let payload;
        try {
            payload = jwt.verify(refresh_token, process.env.JWT_REFRESH_SECRET);
        } catch (err) {
            return res.status(401).json({
                success: false,
                message: 'Invalid or expired refresh token.'
            });
        }

        // 3. Determine collection from role in token payload
        const collection = payload.role === 'teacher' ? 'teachers' : 'students';

        // 4. Find user and check stored refresh token matches
        const userDoc = await db.collection(collection).doc(payload.id).get();

        if (!userDoc.exists) {
            return res.status(404).json({
                success: false,
                message: 'User not found.'
            });
        }

        const userData = userDoc.data();

        // 5. Check stored token matches — prevents reuse after logout
        if (userData.refreshToken !== refresh_token) {
            return res.status(401).json({
                success: false,
                message: 'Refresh token has been revoked.'
            });
        }

        // 6. Build new token payload
        const newPayload = {
            id: userDoc.id,
            email: userData.email,
            role: payload.role,
        };

        // 7. Rotate both tokens
        const newAccessToken = await generateAccessToken(newPayload);
        const newRefreshToken = await generateRefreshToken(newPayload);

        // 8. Store new refresh token in DB (old one is now invalid)
        await userDoc.ref.update({ refreshToken: newRefreshToken });

        return res.status(200).json({
            success: true,
            message: 'Token refreshed successfully.',
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
            role: payload.role,
        });

    } catch (e) {
        return res.status(500).json({ success: false, message: e.toString() });
    }
};
export const logout = async (req, res) => {
    try {
        const { refresh_token } = req.body;

        if (!refresh_token) {
            return res.status(400).json({ success: false, message: 'Refresh token is required.' });
        }

        // 1. Verify the token to get role + id (same as refreshToken endpoint)
        let payload;
        try {
            payload = jwt.verify(refresh_token, process.env.JWT_REFRESH_SECRET);
        } catch (err) {
            // Token already expired or invalid — still fine, just respond success
            return res.status(200).json({ success: true, message: 'Logged out.' });
        }

        // 2. Determine collection from role
        const collection = payload.role === 'teacher' ? 'teachers' : 'students';

        // 3. Find user by id
        const userDoc = await db.collection(collection).doc(payload.id).get();

        if (!userDoc.exists) {
            return res.status(200).json({ success: true, message: 'Logged out.' });
        }

        // 4. Check token actually matches what's stored
        const userData = userDoc.data();
        if (userData.refreshToken !== refresh_token) {
            return res.status(200).json({ success: true, message: 'Already logged out.' });
        }

        // 5. Delete the refresh token from Firestore
        await userDoc.ref.update({
            refreshToken: FieldValue.delete()
        });

        return res.status(200).json({ success: true, message: 'Logged out successfully.' });

    } catch (e) {
        console.log(e);
        return res.status(500).json({ success: false, message: e.toString() });
    }
};