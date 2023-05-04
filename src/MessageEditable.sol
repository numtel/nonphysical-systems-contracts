// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Message.sol";
import "./IMessageEditable.sol";

contract MessageEditable is Ownable, Message {
  uint256 public lastEdited;

  event MessageChanged(string oldValue, string newValue);
  
  constructor(string memory _message, address _owner) Message(_message) {
    _transferOwnership(_owner);
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IMessageEditable).interfaceId || super.supportsInterface(interfaceId);
  }

  function editMessage(string memory newValue) external onlyOwner {
    emit MessageChanged(message, newValue);
    message = newValue;
  }
}
