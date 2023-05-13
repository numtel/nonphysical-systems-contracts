// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Attr.sol";

contract AttrMessage is Attr {
  uint256 public override constant propertyCount = 2;

  mapping(address => string) public value;
  mapping(address => uint) public lastSet;

  function set(address item, string memory newValue) external onlyItemOwner(item) {
    value[item] = newValue;
    lastSet[item] = block.timestamp;
  }

  function properties(address item) external override view returns(Property[] memory out) {
    out = new Property[](propertyCount);

    out[0].key = "message";
    out[0].valueType = "string";
    out[0].value = abi.encodePacked(value[item]);
    out[1].key = "messageSetAt";
    out[1].valueType = "uint256";
    out[1].value = abi.encodePacked(lastSet[item]);
  }
}
