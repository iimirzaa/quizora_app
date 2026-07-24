import express, { urlencoded } from "express";
import  dotenv from 'dotenv';
import AuthRouter from './routes/auth_routes.js';
import QuizRouter  from "./routes/quiz_routes.js";
const app=express();
dotenv.config();
const PORT=process.env.PORT||3000;
app.use(express.json());
app.use(express.urlencoded({extended:true}));
app.use("/quizora/auth",AuthRouter)
app.use('/quizora/quiz',QuizRouter)
app.get("/home",(req,res)=>{
    res.send("Ok");
})
app.listen(PORT,()=>{
 console.log(`Server is runing ${PORT}`);
})