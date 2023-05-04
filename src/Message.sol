// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./IMessage.sol";

contract Message is ERC165 {
  string public message;
  uint256 public created;

  constructor(string memory _message) {
    message = _message;
    created = block.timestamp;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IMessage).interfaceId || super.supportsInterface(interfaceId);
  }
}
