// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IAllowReplies is IERC165 {
  function addReply(address reply) external;
  function replyCount() external view returns(uint256);
  function replies(uint256 index) external view returns(address);
}


