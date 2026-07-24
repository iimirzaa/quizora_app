import jwt from "jsonwebtoken";  
import dotenv from "dotenv";
dotenv.config();

export const generateAccessToken = async (payload) => {
    return jwt.sign(
        payload,
        process.env.JWT_SECRET,
        { expiresIn: '15m' }
    );
};

export const generateRefreshToken = async (payload) => {
    return jwt.sign(
        payload,
        process.env.JWT_REFRESH_SECRET,
        { expiresIn: '7d' }
    );
};