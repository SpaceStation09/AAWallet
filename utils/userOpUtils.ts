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

export function packUserOp(op: UserOperation): string {
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
      keccak256(op.initCode),
      keccak256(op.callData),
      op.callGasLimit,
      op.verificationGasLimit,
      op.preVerificationGas,
      op.maxFeePerGas,
      op.maxPriorityFeePerGas,
      keccak256(op.paymasterAndData),
    ]
  );
}

export function getUserOpWithEnv(userOp: UserOperation, entryPoint: string, chainId: number): string {
  const userOpHash = keccak256(packUserOp(userOp));
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