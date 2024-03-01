import crypto from "crypto";
import fs from "fs";
import { solidityPacked } from "ethers";
import { formatPubKey } from "./utils";


interface Message {
  x: string,
  y: string,
  r: string,
  s: string,
  packedSig: string,
  hash: string,
  msg: string,
}
async function main(){
  const p256 = {name: "ECDSA", namedCurve: "P-256", hash: "SHA-256"};
  const key = await crypto.subtle.generateKey(p256, true, ["sign", "verify"]);
  const pubKeyDer = await crypto.subtle.exportKey("spki", key.publicKey);
  const pubKeyHex = Buffer.from(pubKeyDer).toString("hex");

  const msg: string = "Hello, Secp256r1!";
  const msgBuf = Buffer.from(msg, "hex");
  const msgHash = Buffer.from(await crypto.subtle.digest("SHA-256", msgBuf));
  const sigRaw = await crypto.subtle.sign(p256, key.privateKey, msgBuf);

  const {x, y} = formatPubKey(pubKeyHex);

  const r = Buffer.from(sigRaw).subarray(0,32).toString("hex");
  const s = Buffer.from(sigRaw).subarray(32,64).toString("hex");
  const packedSig = solidityPacked(
    ["uint256", "uint256"],
    [`0x${r}`, `0x${s}`]
  );

  const validMsg: Message = {
    x,
    y,
    r,
    s,
    packedSig,
    hash: msgHash.toString("hex"),
    msg,
  };


  const file_path = "./utils/example-msg.json";
  console.log(`Writing valid msg example to ${file_path}`);
  fs.writeFileSync(file_path, JSON.stringify(validMsg));
}

main();