// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Message.sol";

contract MessageTest is Test {
  function testMessage(string memory _msg) public {
    Message instance = new Message(_msg);
    assertEq(instance.message(), _msg);
    assertEq(instance.created(), block.timestamp);
    assertEq(instance.supportsInterface(type(IMessage).interfaceId), true);
  }
}
