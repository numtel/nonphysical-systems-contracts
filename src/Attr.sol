// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract Attr {
  struct Property {
    string key;
    bytes value;
    string valueType;
  }
  function propertyCount() external virtual pure returns(uint256);
  function properties(address item) external virtual view returns(Property[] memory);

  modifier onlyItemOwner(address item) {
    require(IOwnable(item).owner() == msg.sender, "Ownable: caller is not the owner");
    _;
  }
}

interface IOwnable {
  function owner() external view returns(address);
}
