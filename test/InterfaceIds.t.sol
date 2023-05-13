// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/IAllowReplies.sol";
import "../src/IAllowRepliesStatus.sol";
import "../src/IMessage.sol";
import "../src/IMessageEditable.sol";

contract InterfaceIdsTest is Test {
  function testPrintInterfaceIds() public view {
    console.log("{ \"interfaceIds\": {");
    console.log("\"%s\": \"IAllowReplies\",", vm.toString(abi.encodePacked(type(IAllowReplies).interfaceId)));
    console.log("\"%s\": \"IAllowRepliesStatus\",", vm.toString(abi.encodePacked(type(IAllowRepliesStatus).interfaceId)));
    console.log("\"%s\": \"IMessage\",", vm.toString(abi.encodePacked(type(IMessage).interfaceId)));
    console.log("\"%s\": \"IMessageEditable\"", vm.toString(abi.encodePacked(type(IMessageEditable).interfaceId)));
    console.log("} }");
  }
}
