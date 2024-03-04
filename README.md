# AAWallet With P256 (WIP)

## 目前主要合约

### P256Check

主要用于检测各种情况下 签名 与 hash 计算的正确性

### P256Account

提供一个Secp256k1 keypair 作为owner，一个 secp256r1 keypair 作为权限管理的aa 账户。

## 脚本

### generateSig.ts

本脚本用于生成一套验证普通字符串签名的example。（详见结果于`example-msg.json`）

#### 普通字符串签名流程

- 字符串被直接hash 得到 `hash`;
- 我们使用web crypto的方法，对`hash` 进行签名：`await crypto.subtle.sign(p256, key.privateKey, hash);`

### generateUserOpSig.ts

本脚本用于生成一套验证`UserOperation`签名的example。

#### UserOperation的签名流程

`UserOperation` 会被进行一系列预处理后，再送去签名：
  
- `UserOperation` 中部分类型为`bytes`的字段，在用做签名内容时，会被替代为其的hash值（keccak256）。之后，整个UserOperation会被打包为一个字符串(`hash1`)。
- 被打包的 `UserOperation` (`hash1`) 会再被hash一次(keccak256),得到`hash2`。
- `hash2` 会被和 entrypoint address, chainid 打包在一起，并再一次hash(sha256)，得到最终的`userOpHash`。
- 最后，我们使用web crypto的方法，对`UserOperation` 进行签名：`await crypto.subtle.sign(p256, key.privateKey, userOp);`