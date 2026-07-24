import admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";
import dotenv from 'dotenv';
dotenv.config();

import serviceAccount from "../config/quizora_config.json" with { type: "json" };

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),

});
const auth = admin.auth();
const db=admin.firestore();

export {auth,db,FieldValue};
