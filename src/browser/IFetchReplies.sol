// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IFetchReplies {
  function interfaceId() external pure returns(bytes4);

  struct Property {
    string key;
    bytes value;
    string valueType;
  }

  struct ReplyDetails {
    address item;
    Property[] props;
  }

  struct RepliesResponse {
    ReplyDetails[] items;
    uint totalCount;
    uint lastScanned;
  }

  function fetchReplies(
    address post,
    uint startIndex,
    uint fetchCount,
    bool reverseScan
  ) external view returns(RepliesResponse memory);
}
