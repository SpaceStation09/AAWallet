export const formatPubKey = (publicKey: string): { x: string; y: string } => {
  const pubKey = Buffer.from(publicKey.substring(54), "hex");
  assert(pubKey.length === 64, "pubkey must be 64 bytes");
  const x = `${pubKey.subarray(0, 32).toString("hex")}`;
  const y = `${pubKey.subarray(32).toString("hex")}`;

  return { x, y };
};

export function assert(cond: boolean, msg: string) {
  if (!cond) throw new Error(msg);
}
