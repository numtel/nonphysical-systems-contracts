// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IFetch.sol";

import "../IMessage.sol";

contract FetchMessage is IFetch {
  bytes4 public constant interfaceId = type(IMessage).interfaceId;
  uint256 public constant propertyCount = 2;

  function properties(address item) external view returns(Property[] memory out) {
    out = new Property[](propertyCount);
    IMessage instance = IMessage(item);

    out[0].key = "message";
    out[0].valueType = "string";
    out[0].value = abi.encodePacked(instance.message());
    out[1].key = "created";
    out[1].valueType = "uint256";
    out[1].value = abi.encodePacked(instance.created());
  }
}
