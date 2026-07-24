import argon2 from "argon2";
export const hashOtp=async(otp)=>{
   return await argon2.hash(otp, {
  type: argon2.argon2id,   
  memoryCost: 2 ** 16,     
  timeCost: 3,             
  parallelism: 1,
});
}
export const verifyUserOtp = async (hashed, input) => {
  return await argon2.verify(hashed, input);
};