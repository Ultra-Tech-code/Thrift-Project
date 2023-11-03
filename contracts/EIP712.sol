// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.12;

// contract EIP712{

//     struct Transaction {
//         address payable to;
//         uint256 amount;
//         uint256 nonce;
//       }
      
//       function hashTransaction(Transaction calldata transaction) public view returns (bytes32) {
//         return keccak256(
//           abi.encodePacked(byte(0x19), byte(0x01), DOMAIN_SEPARATOR, TRANSACTION_TYPE,
//           keccak256(abi.encode(transaction.to, transaction.amount, transaction.nonce))
//           )
//         );
//       }
// }