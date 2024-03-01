import { ZeroAddress, solidityPacked } from "ethers";
import { DEFAULT_USER_OPERATION, getUserOpWithEnv } from "./userOpUtils";
import crypto from "crypto";
import { formatPubKey, MsgExample } from "./utils";
import fs from "fs";

async function main(){
  const file_path = "./utils/example-userOp.json";
  const p256 = {name: "ECDSA", namedCurve: "P-256", hash: "SHA-256"};
  let pubKeyDer: ArrayBuffer;
  let privateKey: crypto.webcrypto.CryptoKey;
  let validExample: Partial<MsgExample> = {};

  if(fs.existsSync(file_path)){
    console.log("Reading keypair from example JSON.....");
    const content = fs.readFileSync(file_path, "utf8");
    let keyInfo: MsgExample = JSON.parse(content);
    const exportedPrvKey = keyInfo.exPrvKey;
    const exportedPubKey = keyInfo.exPubKey;
    const publicKey = await crypto.subtle.importKey("jwk", exportedPubKey, p256, true, ["verify"]);
    pubKeyDer = await crypto.subtle.exportKey("spki", publicKey);
    privateKey = await crypto.subtle.importKey("jwk", exportedPrvKey, p256, true, ["sign"]);
    validExample.exPrvKey = keyInfo.exPrvKey;
    validExample.exPubKey = keyInfo.exPubKey;
  } else {
    console.log("Generating new keypair.....");
    const key = await crypto.subtle.generateKey(p256, true, ["sign", "verify"]);
    privateKey = key.privateKey;
    const exportedPrvKey = await crypto.subtle.exportKey("jwk", key.privateKey);
    const exportedPubKey = await crypto.subtle.exportKey("jwk", key.publicKey);
    pubKeyDer = await crypto.subtle.exportKey("spki", key.publicKey);
    validExample.exPrvKey = exportedPrvKey;
    validExample.exPubKey = exportedPubKey;
  }

  // const userOpEnvStr = (
  //   await getUserOpWithEnv(DEFAULT_USER_OPERATION, ZeroAddress, 0)
  // ).substring(2);
  // const userOpEnvBuf = Buffer.from(userOpEnvStr, "hex");
  // const userOpHash = Buffer.from(
  //   await crypto.subtle.digest("SHA-256", userOpEnvBuf)
  // );

}

main();