// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IFetch {
  struct Property {
    string key;
    bytes value;
    string valueType;
  }
  function interfaceId() external pure returns(bytes4);
  function propertyCount() external pure returns(uint256);
  function properties(address item) external view returns(Property[] memory);
}
