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
    console.log("\"IAllowReplies\": \"%s\",", vm.toString(abi.encodePacked(type(IAllowReplies).interfaceId)));
    console.log("\"IAllowRepliesStatus\": \"%s\",", vm.toString(abi.encodePacked(type(IAllowRepliesStatus).interfaceId)));
    console.log("\"IMessage\": \"%s\",", vm.toString(abi.encodePacked(type(IMessage).interfaceId)));
    console.log("\"IMessageEditable\": \"%s\"", vm.toString(abi.encodePacked(type(IMessageEditable).interfaceId)));
    console.log("} }");
  }
}
