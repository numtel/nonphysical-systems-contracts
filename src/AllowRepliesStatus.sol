// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./AllowReplies.sol";
import "./IAllowRepliesStatus.sol";

contract AllowRepliesStatus is AllowReplies {
  mapping(address => int32) public replyStatus;
  uint256 public replyCountLTZero;

  event ReplyStatusUpdated(address indexed item, int32 oldStatus, int32 newStatus);

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IAllowRepliesStatus).interfaceId || super.supportsInterface(interfaceId);
  }

  function replyCountGTEZero() external view returns(uint256) {
    return replies.length - replyCountLTZero;
  }

  struct ReplyStatus {
    address item;
    int32 status;
  }

  function _setReplyStatus(ReplyStatus[] memory newStatus) internal {
    if(newStatus.length > 0) {
      for(uint256 i = 0; i < newStatus.length; i++) {
        int32 oldVal = replyStatus[newStatus[i].item];
        int32 newVal = newStatus[i].status;
        if(oldVal == newVal) continue;
        require(newVal != 0);
        emit ReplyStatusUpdated(newStatus[i].item, oldVal, newVal);
        replyStatus[newStatus[i].item] = newVal;

        bool changedSign = (oldVal > 0 && newVal < 0) || (oldVal < 0 && newVal > 0);
        if(changedSign) {
          if(newVal > 0) replyCountLTZero--;
          else replyCountLTZero++;
        }
      }
    }
  }
}

