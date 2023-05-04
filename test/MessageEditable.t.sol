// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/MessageEditable.sol";

contract MessageEditableTest is Test {
  event MessageChanged(string oldValue, string newValue);

  function testMessageEditable(string memory _msg1, string memory _msg2) public {
    MessageEditable instance = new MessageEditable(_msg1, address(this));
    assertEq(instance.message(), _msg1);
    assertEq(instance.supportsInterface(type(IMessage).interfaceId), true);
    assertEq(instance.supportsInterface(type(IMessageEditable).interfaceId), true);

    vm.expectEmit(true, true, false, true);
    emit MessageChanged(_msg1, _msg2);
    instance.editMessage(_msg2);
    assertEq(instance.message(), _msg2);
  }

  function testFailMessageEditable(string memory _msg1, string memory _msg2) public {
    MessageEditable instance = new MessageEditable(_msg1, address(this));
    vm.prank(address(1));
    instance.editMessage(_msg2);
  }
}

