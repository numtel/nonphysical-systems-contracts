// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IFetch.sol";

import "../IAllowRepliesStatus.sol";

contract FetchAllowRepliesStatus is IFetch {
  bytes4 public constant interfaceId = type(IAllowRepliesStatus).interfaceId;
  uint256 public constant propertyCount = 2;

  function properties(address item) external view returns(Property[] memory out) {
    out = new Property[](propertyCount);
    IAllowRepliesStatus instance = IAllowRepliesStatus(item);

    out[0].key = "replyCountLTZero";
    out[0].valueType = "uint256";
    out[0].value = abi.encodePacked(instance.replyCountLTZero());
    out[1].key = "replyCountGTEZero";
    out[1].valueType = "uint256";
    out[1].value = abi.encodePacked(instance.replyCountGTEZero());
  }
}


