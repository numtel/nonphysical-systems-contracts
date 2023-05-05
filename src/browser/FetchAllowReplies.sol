// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IFetch.sol";

import "../IAllowReplies.sol";

contract FetchAllowReplies is IFetch {
  bytes4 public constant interfaceId = type(IAllowReplies).interfaceId;
  uint256 public constant propertyCount = 1;

  function properties(address item) external view returns(Property[] memory out) {
    out = new Property[](propertyCount);
    IAllowReplies instance = IAllowReplies(item);

    out[0].key = "replyCount";
    out[0].valueType = "uint256";
    out[0].value = abi.encodePacked(instance.replyCount());
  }
}


