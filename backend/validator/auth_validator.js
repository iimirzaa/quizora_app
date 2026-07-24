import Joi from 'joi';
export const loginSchema=Joi.object({
    email:Joi.string().email().required(),
     password: Joi.string()
    .min(8)
    .pattern(new RegExp("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[A-Za-z\\d]+$"))
    .required()
    .messages({
      "string.pattern.base":
        "Password must contain uppercase, lowercase, and a number, and no special characters"
    })
});
export const signUpSchema=Joi.object({
  name:Joi.string().min(3).required(),
  email:Joi.string().email().required(),
  password: Joi.string()
    .min(8)
    .pattern(new RegExp("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[A-Za-z\\d]+$"))
    .required()
    .messages({
      "string.pattern.base":
        "Password must contain uppercase, lowercase, and a number, and no special characters"
    }),
    role: Joi.string().valid('teacher', 'student').required(),
})
export const verifyOtpSchema=Joi.object({
  email:Joi.string().email().required(),
  otp:Joi.string().pattern(/^[0-9]+$/).min(6).required(),
  role: Joi.string().valid('teacher', 'student').required(),
})