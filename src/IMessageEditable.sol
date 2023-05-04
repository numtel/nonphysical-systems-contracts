// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IMessage.sol";
import "./IOwnable.sol";

interface IMessageEditable is IMessage, IOwnable {
  event MessageChanged(string oldValue, string newValue);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  function lastEdited() external view returns(uint256);
  function editMessage(string memory newValue) external;
}
