import { BigNumberish, ZeroAddress, keccak256 } from "ethers";
import { AbiCoder } from "ethers";
import crypto from "crypto";


export interface UserOperation {
  sender: string;
  nonce: number;
  initCode: string;
  callData: string;
  callGasLimit: BigNumberish;
  verificationGasLimit: BigNumberish;
  preVerificationGas: BigNumberish;
  maxFeePerGas: BigNumberish;
  maxPriorityFeePerGas: BigNumberish;
  paymasterAndData: string;
  signature: string;
}

export async function packUserOp(op: UserOperation): Promise<string> {
  return AbiCoder.defaultAbiCoder().encode(
    [
      "address",
      "uint256",
      "bytes32",
      "bytes32",
      "uint256",
      "uint256",
      "uint256",
      "uint256",
      "uint256",
      "bytes32",
    ],
    [
      op.sender,
      op.nonce,
      await sha256(op.initCode),
      await sha256(op.callData),
      op.callGasLimit,
      op.verificationGasLimit,
      op.preVerificationGas,
      op.maxFeePerGas,
      op.maxPriorityFeePerGas,
      await sha256(op.paymasterAndData),
    ]
  );
}

export async function getUserOpWithEnv(userOp: UserOperation, entryPoint: string, chainId: number): Promise<string> {
  const userOpHash = await sha256((await packUserOp(userOp)).substring(2));
  const enc = AbiCoder.defaultAbiCoder().encode(
    ["bytes32", "address", "uint256"],
    [userOpHash, entryPoint, chainId]
  );
  return enc;
}

export const DEFAULT_USER_OPERATION: UserOperation = {
  sender: ZeroAddress,
  nonce: 0,
  initCode: "0x",
  callData:"0x",
  callGasLimit: 0,
  verificationGasLimit: 0,
  preVerificationGas: 0,
  maxFeePerGas: 0,
  maxPriorityFeePerGas: 0,
  paymasterAndData: "0x",
  signature: "0x",
};

const sha256 = async (msg: string): Promise<string> => {
  const msgBuf = Buffer.from(msg, "hex");
  const msgHash = Buffer.from(await crypto.subtle.digest("SHA-256", msgBuf));
  return `0x${msgHash.toString("hex")}`;
}