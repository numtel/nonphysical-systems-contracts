// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/PostBrowser.sol";
import "../src/browser/FetchMessage.sol";
import "../src/browser/FetchMessageEditable.sol";
import "../src/browser/FetchAllowReplies.sol";
import "../src/browser/FetchAllowRepliesStatus.sol";
import "../src/browser/FetchRepliesStatus.sol";

contract Deploy is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    address[] memory fetchers = new address[](4);
    fetchers[0] = address(new FetchMessage());
    fetchers[1] = address(new FetchMessageEditable());
    fetchers[2] = address(new FetchAllowReplies());
    fetchers[3] = address(new FetchAllowRepliesStatus());

    address[] memory replyFetchers = new address[](1);
    replyFetchers[0] = address(new FetchRepliesStatus(0));

    new PostBrowser(fetchers, replyFetchers);

    vm.stopBroadcast();
  }
}

