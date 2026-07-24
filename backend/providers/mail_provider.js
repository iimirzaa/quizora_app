import  nodemailer from "nodemailer";
import dotenv from "dotenv";
dotenv.config();
export const sendMail=async (mail,otp)=> {
const transporter= nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.MAIL_ID,
    pass: process.env.MAIL_PASSWORD,
  },
});


var mailOptions = {
  from: process.env.MAIL_ID,
  to: mail,
  subject: "One-Time verfication key- Quizora",
  html: `
  <!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Email Verification</title>
  </head>
  <body style="font-family: Arial, sans-serif; color: #333; margin: 0; padding: 20px;">
      <div style="max-width: 600px; margin: auto; padding: 20px; background-color: #f9f9f9; border-radius: 8px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
          <h2 style="text-align: center; color: #2E6ADA;">Email Verification</h2>
          <p>Hello,</p>
          <p>Thank you for registering with us! To complete your email verification, please use the following one-time password (OTP):</p>
          <h3 style="text-align: center; background-color: #f1f1f1; padding: 10px; border-radius: 4px; color: #49A2E6;">
              <strong>${otp}</strong>
          </h3>
          <p style="font-size: 14px; color: #555;">This OTP is valid for the next <strong>5 minutes</strong>. Please enter it on the verification page to confirm your email address.</p>
          <p>If you did not request this verification, you can safely ignore this email.</p>
          <p style="margin-top: 20px; text-align: center; font-size: 14px; color: #888;">Best regards,<br>Team Quizora</p>
          
      </div>
  </body>
  </html>
`
};


    
    try{
await transporter.sendMail(mailOptions);

    console.log("Otp sent succesfully");
    return otp;

}catch(e){
    console.log("There was error while sending email");
   console.log(e);
}
}

