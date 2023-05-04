// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IAllowReplies.sol";

contract ReplyBrowser {
  struct RepliesResponse {
    address[] items;
    uint totalCount;
    uint lastScanned;
  }

  function fetchReplies(
    IAllowReplies post,
    uint startIndex,
    uint fetchCount,
    bool reverseScan
  ) external view returns(RepliesResponse memory) {
    if(post.replyCount() == 0) return RepliesResponse(new address[](0), 0, 0);
    require(startIndex < post.replyCount());
    if(startIndex + fetchCount >= post.replyCount()) {
      fetchCount = post.replyCount() - startIndex;
    }
    address[] memory selection = new address[](fetchCount);
    uint i;
    uint replyIndex = startIndex;
    if(reverseScan) {
      replyIndex = post.replyCount() - 1 - startIndex;
    }
    while(true) {
      selection[i] = post.replies(replyIndex);
      i++;
      if(reverseScan) {
        if(replyIndex == 0 || i == fetchCount) break;
        replyIndex--;
      } else {
        if(replyIndex == post.replyCount() - 1) break;
        replyIndex++;
      }
    }

    return RepliesResponse(selection, post.replyCount(), replyIndex);
  }
}
