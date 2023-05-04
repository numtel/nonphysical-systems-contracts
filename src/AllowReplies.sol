// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./IAllowReplies.sol";

contract AllowReplies is ERC165 {
  address[] public replies;

  event ReplyAdded(address indexed item, uint256 indexed replyIndex);

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IAllowReplies).interfaceId || super.supportsInterface(interfaceId);
  }

  function addReply(address reply) external {
    emit ReplyAdded(reply, replies.length);
    replies.push(reply);
  }

  function replyCount() external view returns(uint256) {
    return replies.length;
  }
}
