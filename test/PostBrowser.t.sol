// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/PostBrowser.sol";
import "../src/PostV1.sol";
import "../src/browser/FetchMessage.sol";
import "../src/browser/FetchMessageEditable.sol";
import "../src/browser/FetchAllowReplies.sol";
import "../src/browser/FetchAllowRepliesStatus.sol";
import "../src/browser/FetchRepliesStatus.sol";

contract PostBrowserTest is Test {
  function testReplies(string memory _msg1, string memory _msg2, int32 status1) public {
    PostV1Factory factory = new PostV1Factory();
    PostV1 root = factory.createNew(_msg1, address(0));
    PostV1 child1 = factory.createNew(_msg2, address(root));
    PostV1.ReplyStatus[] memory setStatus1 = new PostV1.ReplyStatus[](1);
    setStatus1[0].item = address(child1);
    setStatus1[0].status = status1;
    root.setReplyStatus(setStatus1);

    address[] memory fetchers = new address[](1);
    fetchers[0] = address(new FetchMessage());
    address[] memory replyFetchers = new address[](1);
    replyFetchers[0] = address(new FetchRepliesStatus(type(int32).min));
    PostBrowser browser = new PostBrowser(fetchers, replyFetchers);

    IFetchReplies.RepliesResponse memory result = browser.fetchReplies(address(root), 0, 10, false);
    assertEq(result.items.length, 1);
    assertEq(result.items[0].props.length, 4);
    assertEq(result.items[0].props[0].key, "status");
    assertEq(result.items[0].props[0].valueType, "int32");
    assertEq(int32(uint32(bytes4(result.items[0].props[0].value))), status1);
    assertEq(result.items[0].props[1].key, "message");
    assertEq(result.items[0].props[1].valueType, "string");
    assertEq(string(result.items[0].props[1].value), _msg2);
    assertEq(result.items[0].props[2].key, "created");
    assertEq(result.items[0].props[2].valueType, "uint256");
    assertEq(uint256(bytes32(result.items[0].props[2].value)), block.timestamp);
    assertEq(result.items[0].props[3].key, "matchingInterfaces");
    assertEq(result.items[0].props[3].valueType, "bytes4[]");
    bytes4[] memory fromQuery = bytesToBytes4Array(result.items[0].props[3].value);
    for(uint i = 0; i < fromQuery.length; i++) {
      if(uint32(fromQuery[i]) == 0) continue;
      assertEq(fromQuery[i], type(IMessage).interfaceId);
    }
  }

  function testProperties(string memory _msg1, string memory _msg2) public {
    PostV1Factory factory = new PostV1Factory();
    PostV1 root = factory.createNew(_msg1, address(0));
    factory.createNew(_msg2, address(root));

    address[] memory fetchers = new address[](4);
    fetchers[0] = address(new FetchMessage());
    fetchers[1] = address(new FetchMessageEditable());
    fetchers[2] = address(new FetchAllowReplies());
    fetchers[3] = address(new FetchAllowRepliesStatus());
    address[] memory replyFetchers = new address[](0);
    PostBrowser browser = new PostBrowser(fetchers, replyFetchers);

    bytes4[] memory interfaces = browser.matchingInterfaces(address(root));
    assertEq(interfaces.length, 4);
    for(uint i = 0; i < interfaces.length; i++) {
      // Don't enforce order
      assertEq(interfaces[i] == type(IMessage).interfaceId
        || interfaces[i] == type(IMessageEditable).interfaceId
        || interfaces[i] == type(IAllowReplies).interfaceId
        || interfaces[i] == type(IAllowRepliesStatus).interfaceId
      , true);
    }


    IFetch.Property[] memory props = browser.properties(address(root));
    assertEq(props.length, 7);
    for(uint i = 0; i < props.length; i++) {
      // Don't enforce prop order
      if(stringEqual(props[i].key, "message")) {
        assertEq(props[i].valueType, "string");
        assertEq(string(props[i].value), _msg1);
      } else if(stringEqual(props[i].key, "created")) {
        assertEq(props[i].valueType, "uint256");
        assertEq(uint256(bytes32(props[i].value)), block.timestamp);
      } else if(stringEqual(props[i].key, "lastEdited")) {
        assertEq(props[i].valueType, "uint256");
        assertEq(uint256(bytes32(props[i].value)), 0);
      } else if(stringEqual(props[i].key, "owner")) {
        assertEq(props[i].valueType, "address");
        assertEq(props[i].value.length, 20);
        address addr;
        bytes memory data = props[i].value;
        assembly {
            addr := mload(add(data, 20))
        }

        assertEq(addr, address(this));
      } else if(stringEqual(props[i].key, "replyCount")) {
        assertEq(props[i].valueType, "uint256");
        assertEq(uint256(bytes32(props[i].value)), 1);
      } else if(stringEqual(props[i].key, "replyCountLTZero")) {
        assertEq(props[i].valueType, "uint256");
        assertEq(uint256(bytes32(props[i].value)), 0);
      } else if(stringEqual(props[i].key, "replyCountGTEZero")) {
        assertEq(props[i].valueType, "uint256");
        assertEq(uint256(bytes32(props[i].value)), 1);
      }
    }
  }

  // Thanks ChatGPT!
  function stringEqual(string memory a, string memory b) public pure returns(bool) {
    return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
  }

  // Thanks ChatGPT!
  function bytesToBytes4Array(bytes memory input) public pure returns (bytes4[] memory) {
    require(input.length % 4 == 0, "Input bytes length must be a multiple of 4.");

    uint256 arrayLength = input.length / 4;
    bytes4[] memory output = new bytes4[](arrayLength);

    for (uint256 i = 0; i < arrayLength; i++) {
      bytes4 currentBytes4;

      for (uint256 j = 0; j < 4; j++) {
        currentBytes4 |= (bytes4(input[i * 4 + j]) >> (j * 8));
      }

      output[i] = currentBytes4;
    }

    return output;
  }
}
