// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IAllowRepliesStatus.sol";

contract ReplyStatusBrowser {
  struct ReplyDetails {
    address item;
    int32 status;
  }

  struct RepliesResponse {
    ReplyDetails[] items;
    uint totalCount;
    uint lastScanned;
  }

  // Sorting must happen on the client
  function fetchReplies(
    IAllowRepliesStatus post,
    int32 minStatus,
    uint startIndex,
    uint fetchCount,
    bool reverseScan
  ) external view returns(RepliesResponse memory) {
    if(post.replyCount() == 0) return RepliesResponse(new ReplyDetails[](0), 0, 0);
    require(startIndex < post.replyCount());
    if(startIndex + fetchCount >= post.replyCount()) {
      fetchCount = post.replyCount() - startIndex;
    }
    address[] memory selection = new address[](fetchCount);
    uint activeCount;
    uint i;
    uint replyIndex = startIndex;
    if(reverseScan) {
      replyIndex = post.replyCount() - 1 - startIndex;
    }
    while(true) {
      selection[i] = post.replies(replyIndex);
      if(post.replyStatus(selection[i]) >= minStatus) activeCount++;
      if(activeCount == fetchCount) break;
      if(reverseScan) {
        if(replyIndex == 0) break;
        replyIndex--;
      } else {
        if(replyIndex == post.replyCount() - 1) break;
        replyIndex++;
      }
      i++;
    }

    ReplyDetails[] memory out = new ReplyDetails[](activeCount);
    uint j;
    for(i=0; i<fetchCount; i++) {
      if(post.replyStatus(selection[i]) >= minStatus) {
        out[j++] = ReplyDetails(
          selection[i],
          post.replyStatus(selection[i])
        );
      }
    }
    return RepliesResponse(out, post.replyCount(), replyIndex);
  }
}
