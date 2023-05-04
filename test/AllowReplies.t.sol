// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/AllowReplies.sol";
import "../src/ReplyBrowser.sol";

contract AllowRepliesTest is Test {
  event ReplyAdded(address indexed item, uint256 indexed replyIndex);

  function testAddReply(address _reply1, address _reply2) public {
    AllowReplies instance = new AllowReplies();
    assertEq(instance.supportsInterface(type(IAllowReplies).interfaceId), true);

    vm.expectEmit(true, true, false, true);
    emit ReplyAdded(_reply1, 0);
    instance.addReply(_reply1);
    assertEq(instance.replyCount(), 1);
    assertEq(instance.replies(0), _reply1);

    ReplyBrowser browser = new ReplyBrowser();
    ReplyBrowser.RepliesResponse memory result1 = browser.fetchReplies(IAllowReplies(address(instance)), 0, 10, false);
    assertEq(result1.totalCount, 1);
    assertEq(result1.lastScanned, 0);
    assertEq(result1.items[0], _reply1);

    instance.addReply(_reply2);
    ReplyBrowser.RepliesResponse memory result2 = browser.fetchReplies(IAllowReplies(address(instance)), 0, 10, false);
    assertEq(result2.totalCount, 2);
    assertEq(result2.lastScanned, 1);
    assertEq(result2.items[0], _reply1);
    assertEq(result2.items[1], _reply2);

    ReplyBrowser.RepliesResponse memory result3 = browser.fetchReplies(IAllowReplies(address(instance)), 0, 10, true);
    assertEq(result3.totalCount, 2);
    assertEq(result3.lastScanned, 0);
    assertEq(result3.items[0], _reply2);
    assertEq(result3.items[1], _reply1);

    ReplyBrowser.RepliesResponse memory result4 = browser.fetchReplies(IAllowReplies(address(instance)), 0, 1, true);
    assertEq(result4.totalCount, 2);
    assertEq(result4.lastScanned, 1);
    assertEq(result4.items[0], _reply2);
    assertEq(result4.items.length, 1);

    ReplyBrowser.RepliesResponse memory result5 = browser.fetchReplies(IAllowReplies(address(instance)), 1, 1, true);
    assertEq(result5.totalCount, 2);
    assertEq(result5.lastScanned, 0);
    assertEq(result5.items[0], _reply1);
    assertEq(result5.items.length, 1);
  }
}
