// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// EIP-XXXX: Contract Comments (Social Media: Web3 2.0)
interface IPost {
  function message() external view returns(string memory);
  function addReply(address reply) external;
}
