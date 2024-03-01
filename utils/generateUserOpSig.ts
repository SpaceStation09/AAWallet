import { ZeroAddress, solidityPacked } from "ethers";
import { DEFAULT_USER_OPERATION, getUserOpWithEnv } from "./userOpUtils";
import crypto from "crypto";
import { formatPubKey } from "./utils";
import fs from "fs";

async function main(){
  const p256 = { name: "ECDSA", namedCurve: "P-256", hash: "SHA-256" };
  const key = await crypto.subtle.generateKey(p256, true, ["sign", "verify"]);
  const pubKeyDer = await crypto.subtle.exportKey("spki", key.publicKey);
  const pubKeyHex = Buffer.from(pubKeyDer).toString("hex");

  const userOpEnvStr = (
    await getUserOpWithEnv(DEFAULT_USER_OPERATION, ZeroAddress, 0)
  ).substring(2);
  const userOpEnvBuf = Buffer.from(userOpEnvStr, "hex");
  const userOpHash = Buffer.from(
    await crypto.subtle.digest("SHA-256", userOpEnvBuf)
  );

  const sigRaw = await crypto.subtle.sign(p256, key.privateKey, userOpHash);
  const verified = await crypto.subtle.verify(
    p256,
    key.publicKey,
    sigRaw,
    userOpHash
  );

  const { x, y } = formatPubKey(pubKeyHex);

  const r = Buffer.from(sigRaw).subarray(0, 32).toString("hex");
  const s = Buffer.from(sigRaw).subarray(32, 64).toString("hex");

  const packedSig = solidityPacked(
    ["uint256", "uint256"],
    [`0x${r}`, `0x${s}`]
  );

  const validMsg = {
    x,
    y,
    r,
    s,
    packedSig,
    verified,
    hash: userOpHash.toString("hex"),
  };

  const file_path = "./utils/example-userOp.json";
  console.log(`Writing valid userOp example to ${file_path}`);
  fs.writeFileSync(file_path, JSON.stringify(validMsg));

}

main();