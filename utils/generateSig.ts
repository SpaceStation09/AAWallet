import crypto from "crypto";
import fs from "fs";
import { solidityPacked } from "ethers";
import { formatPubKey, MsgExample } from "./utils";


async function main(){
  const file_path = "./utils/example-msg.json";
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
  
  const pubKeyHex = Buffer.from(pubKeyDer).toString("hex");

  const msg: string = "Hello, Secp256r1!";
  validExample.msg = msg;
  const msgBuf = Buffer.from(msg);
  const msgHash = Buffer.from(await crypto.subtle.digest("SHA-256", msgBuf));
  const sigRaw = await crypto.subtle.sign(p256, privateKey, msgBuf);

  const {x, y} = formatPubKey(pubKeyHex);

  const r = Buffer.from(sigRaw).subarray(0,32).toString("hex");
  const s = Buffer.from(sigRaw).subarray(32,64).toString("hex");
  const packedSig = solidityPacked(
    ["uint256", "uint256"],
    [`0x${r}`, `0x${s}`]
  );

  validExample.hash = msgHash.toString("hex");
  validExample.x = x;
  validExample.y = y;
  validExample.r = r;
  validExample.s = s;
  validExample.packedSig = packedSig;

  console.log(`Writing valid msg example to ${file_path}`);
  fs.writeFileSync(file_path, JSON.stringify(validExample));
}

main();