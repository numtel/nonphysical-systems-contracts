// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/PostV1.sol";

contract PostV1Test is Test {
  PostV1Factory public factory;

  function setUp() public {
    factory = new PostV1Factory();
  }

  function testFailDoubleAdd(string memory _msg1, string memory _msg2) public {
    vm.assume(bytes(_msg1).length > 5);
    PostV1 parent = factory.createNew(_msg1, PostV1(address(0)));
    assertEq(parent.message(), _msg1);
    PostV1 child1 = factory.createNew(_msg1, parent);
    parent.addReply(IPost(address(child1)));
  }

  function testReply(string memory _msg1, string memory _msg2) public {
    vm.assume(bytes(_msg1).length > 5);
    PostV1 parent = factory.createNew(_msg1, PostV1(address(0)));
    assertEq(parent.message(), _msg1);

    parent.editMessage(_msg2);
    assertEq(parent.message(), _msg2);

    PostV1.RepliesResponse memory fetchNone = parent.fetchReplies(0, 0, 10, false);
    assertEq(fetchNone.totalCount, 0);

    PostV1 child1 = factory.createNew(_msg1, parent);

    PostV1.RepliesResponse memory fetchSingle = parent.fetchReplies(0, 0, 10, false);
    assertEq(fetchSingle.totalCount, 1);

    PostV1 child2 = factory.createNew(_msg1, parent);
    assertEq(parent.replyCount(), 2);
    assertEq(parent.replies(0), address(child1));
    assertEq(parent.replies(1), address(child2));

    PostV1.RepliesResponse memory fetched = parent.fetchReplies(0, 0, 10, false);
    assertEq(fetched.totalCount, 2);
    assertEq(fetched.items[0].message, _msg1);
    assertEq(fetched.items[0].status, int32(1));
    assertEq(fetched.items[0].owner, address(this));
    assertEq(fetched.items[0].item, address(child1));
    assertEq(fetched.items[1].item, address(child2));
    assertEq(fetched.items[1].created, child2.created());

    PostV1.RepliesResponse memory fetchReverse = parent.fetchReplies(0, 0, 10, true);
    assertEq(fetchReverse.items[0].item, address(child2));
    assertEq(fetchReverse.items[1].item, address(child1));

    // Set moderation status of message to out of view
    PostV1.ReplyStatus[] memory setStatus = new PostV1.ReplyStatus[](1);
    setStatus[0].item = address(child1);
    setStatus[0].status = -2;
    parent.setReplyStatus(setStatus);

    PostV1.RepliesResponse memory fetchAfter = parent.fetchReplies(0, 0, 10, false);
    // Still 2 replies exist
    assertEq(fetchAfter.totalCount, 2);
    // But only one matches the specified minStatus
    assertEq(fetchAfter.items.length, 1);

    assertEq(fetchAfter.items[0].item, address(child2));
  }
}
