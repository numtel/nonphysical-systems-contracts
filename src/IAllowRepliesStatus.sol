// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IAllowReplies.sol";

interface IAllowRepliesStatus is IAllowReplies {
  function replyStatus(address item) external view returns(int32);
  function replyCountLTZero() external view returns(uint256);
  function replyCountGTEZero() external view returns(uint256);
  
  struct ReplyStatus {
    address item;
    int32 status;
  }
}
