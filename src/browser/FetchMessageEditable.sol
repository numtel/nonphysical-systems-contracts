// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IFetch.sol";

import "../IMessageEditable.sol";

contract FetchMessageEditable is IFetch {
  bytes4 public constant interfaceId = type(IMessageEditable).interfaceId;
  uint256 public constant propertyCount = 2;

  function properties(address item) external view returns(Property[] memory out) {
    out = new Property[](propertyCount);
    IMessageEditable instance = IMessageEditable(item);

    out[0].key = "lastEdited";
    out[0].valueType = "uint256";
    out[0].value = abi.encodePacked(instance.lastEdited());
    out[1].key = "owner";
    out[1].valueType = "address";
    out[1].value = abi.encodePacked(instance.owner());
  }
}

