import rateLimit from 'express-rate-limit';

const createLimiter = (max, windowMinutes, message) => rateLimit({
    windowMs:        windowMinutes * 60 * 1000,
    max,
    standardHeaders: true,
    legacyHeaders:   false,
    message:         { success: false, message },
});

export const signUpLimiter = createLimiter(5,  15, 'Too many signup attempts. Try again in 15 minutes.');
export const loginLimiter  = createLimiter(10, 1, 'Too many login attempts. Try again in 15 minutes.');
export const otpLimiter    = createLimiter(5,  10, 'Too many OTP attempts. Try again in 10 minutes.');
export const generateMcqLimiter=createLimiter(15,3,"Please Try again after a while");