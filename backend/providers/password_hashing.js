import argon2 from "argon2";

export const hashPassword = async (password) => {
  try {
    console.log("received password:", password);

    const hash = await argon2.hash(password, {
      type: argon2.argon2id,
      memoryCost: 2 ** 16,
      timeCost: 3,
      parallelism: 1,
    });
    

    return hash;
  } catch (err) {
    console.log("HASH ERROR:", err);
    throw err;
  }
};

export const verifyPassword = async (hashed, input) => {
  return await argon2.verify(hashed, input);
};