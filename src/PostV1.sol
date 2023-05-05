// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./MessageEditable.sol";
import "./AllowRepliesStatus.sol";
import "./IAllowReplies.sol";

contract PostV1 is MessageEditable, AllowRepliesStatus {
  constructor(string memory _message, address _owner)
    MessageEditable(_message, _owner) {}

  function supportsInterface(bytes4 interfaceId) public view virtual
      override (AllowRepliesStatus, MessageEditable) returns (bool) {
    return interfaceId == type(IMessageEditable).interfaceId
        || interfaceId == type(IMessage).interfaceId
        || interfaceId == type(IAllowRepliesStatus).interfaceId
        || interfaceId == type(IAllowReplies).interfaceId
        || super.supportsInterface(interfaceId);
  }

  function setReplyStatus(ReplyStatus[] memory newStatus) external onlyOwner {
    _setReplyStatus(newStatus);
  }
}

contract PostV1Factory {
  event NewPost(address indexed post, address indexed parent);

  function createNew(string memory message, address parent) external returns(PostV1 created) {
    created = new PostV1(message, msg.sender);
    emit NewPost(address(created), parent);

    if(parent != address(0)) {
      IAllowReplies(parent).addReply(address(created));
    }
  }
}
