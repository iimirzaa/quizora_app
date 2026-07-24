import express from 'express';
import { loginSchema,signUpSchema,verifyOtpSchema } from '../validator/auth_validator.js';
import {login,signUp, verifyOtp,refreshToken,logout} from '../controller/auth_controller.js';
import { validate } from '../middleware/validate.js';
import { signUpLimiter ,otpLimiter, loginLimiter} from '../middleware/ratelimiter.js';

const AuthRouter=express.Router();
AuthRouter.post('/login',
    loginLimiter,            // 1. rate limit
    validate(loginSchema),   // 2. validate
    login                // 3. controller
);
AuthRouter.post('/sign-up',
    signUpLimiter,            // 1. rate limit
    validate(signUpSchema),   // 2. validate
    signUp                    // 3. controller
);
AuthRouter.post('/verify-otp',
    otpLimiter,            // 1. rate limit
    validate(verifyOtpSchema),   // 2. validate
    verifyOtp                    // 3. controller
);
AuthRouter.post("/refresh-token",
refreshToken
);
AuthRouter.post('/logout',logout);

export default AuthRouter;
