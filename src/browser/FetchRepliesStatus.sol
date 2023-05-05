// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IFetchReplies.sol";

import "../IAllowRepliesStatus.sol";
import "../ReplyStatusBrowser.sol";

contract FetchRepliesStatus is IFetchReplies {
  bytes4 public constant interfaceId = type(IAllowRepliesStatus).interfaceId;

  int32 public minStatus;
  ReplyStatusBrowser browser;

  constructor(int32 _minStatus) {
    minStatus = _minStatus;
    browser = new ReplyStatusBrowser();
  }

  function fetchReplies(
    address post,
    uint startIndex,
    uint fetchCount,
    bool reverseScan
  ) external view returns(RepliesResponse memory out) {
    ReplyStatusBrowser.RepliesResponse memory result = browser.fetchReplies(
      IAllowRepliesStatus(post), minStatus, startIndex, fetchCount, reverseScan);

    out.totalCount = result.totalCount;
    out.lastScanned = result.lastScanned;
    out.items = new ReplyDetails[](result.items.length);
    for(uint i=0; i<result.items.length; i++) {
      out.items[i].item = result.items[i].item;
      out.items[i].props = new Property[](1);
      out.items[i].props[0].key = "status";
      out.items[i].props[0].valueType = "int32";
      out.items[i].props[0].value = abi.encodePacked(result.items[i].status);
    }
  }
}
