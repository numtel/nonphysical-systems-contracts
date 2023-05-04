// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/AllowRepliesStatus.sol";
import "../src/ReplyStatusBrowser.sol";

contract DummyARS is AllowRepliesStatus {
  function setReplyStatus(ReplyStatus[] memory newStatus) external {
    _setReplyStatus(newStatus);
  }
}

contract AllowRepliesStatusTest is Test {
  event ReplyStatusUpdated(address indexed item, int32 oldStatus, int32 newStatus);

  function testSetStatus(address _reply1, address _reply2) public {
    DummyARS instance = new DummyARS();
    assertEq(instance.supportsInterface(type(IAllowReplies).interfaceId), true);
    assertEq(instance.supportsInterface(type(IAllowRepliesStatus).interfaceId), true);

    instance.addReply(_reply1);
    DummyARS.ReplyStatus[] memory setStatus1 = new DummyARS.ReplyStatus[](1);
    setStatus1[0].item = _reply1;
    setStatus1[0].status = 2;
    vm.expectEmit(true, true, false, true);
    emit ReplyStatusUpdated(_reply1, 0, 2);
    instance.setReplyStatus(setStatus1);
    assertEq(instance.replyCountGTEZero(), 1);
    assertEq(instance.replyCountLTZero(), 0);

    DummyARS.ReplyStatus[] memory setStatus2 = new DummyARS.ReplyStatus[](1);
    setStatus2[0].item = _reply1;
    setStatus2[0].status = -2;
    vm.expectEmit(true, true, false, true);
    emit ReplyStatusUpdated(_reply1, 2, -2);
    instance.setReplyStatus(setStatus2);
    assertEq(instance.replyCountGTEZero(), 0);
    assertEq(instance.replyCountLTZero(), 1);

    vm.expectEmit(true, true, false, true);
    emit ReplyStatusUpdated(_reply1, -2, 2);
    instance.setReplyStatus(setStatus1);
    assertEq(instance.replyCountGTEZero(), 1);
    assertEq(instance.replyCountLTZero(), 0);

    ReplyStatusBrowser browser = new ReplyStatusBrowser();
    ReplyStatusBrowser.RepliesResponse memory result1 = browser.fetchReplies(IAllowRepliesStatus(address(instance)), 0, 0, 10, false);
    assertEq(result1.totalCount, 1);
    assertEq(result1.lastScanned, 0);
    assertEq(result1.items[0].item, _reply1);
    assertEq(result1.items[0].status, 2);

    instance.addReply(_reply2);
    ReplyStatusBrowser.RepliesResponse memory result2 = browser.fetchReplies(IAllowRepliesStatus(address(instance)), 0, 0, 10, false);
    assertEq(result2.totalCount, 2);
    assertEq(result2.lastScanned, 1);
    assertEq(result2.items[0].item, _reply1);
    assertEq(result2.items[1].item, _reply2);

    ReplyStatusBrowser.RepliesResponse memory result3 = browser.fetchReplies(IAllowRepliesStatus(address(instance)), 0, 0, 10, true);
    assertEq(result3.totalCount, 2);
    assertEq(result3.lastScanned, 0);
    assertEq(result3.items[0].item, _reply2);
    assertEq(result3.items[1].item, _reply1);

    ReplyStatusBrowser.RepliesResponse memory result4 = browser.fetchReplies(IAllowRepliesStatus(address(instance)), 0, 0, 1, true);
    assertEq(result4.totalCount, 2);
    assertEq(result4.lastScanned, 1);
    assertEq(result4.items[0].item, _reply2);
    assertEq(result4.items.length, 1);

    ReplyStatusBrowser.RepliesResponse memory result5 = browser.fetchReplies(IAllowRepliesStatus(address(instance)), 0, 1, 1, true);
    assertEq(result5.totalCount, 2);
    assertEq(result5.lastScanned, 0);
    assertEq(result5.items[0].item, _reply1);
    assertEq(result5.items.length, 1);

    instance.setReplyStatus(setStatus2);
    // Skip over _reply1 with status of -2
    ReplyStatusBrowser.RepliesResponse memory result6 = browser.fetchReplies(IAllowRepliesStatus(address(instance)), 0, 0, 10, true);
    assertEq(result6.totalCount, 2);
    assertEq(result6.lastScanned, 0);
    assertEq(result6.items[0].item, _reply2);
    assertEq(result6.items.length, 1);
  }
}

