// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/PostV1.sol";
import "../src/ReplyStatusBrowser.sol";

contract Deploy is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    PostV1Factory factory = new PostV1Factory();
    // Create a post so that all posts have a verified contract
    factory.createNew("Hello", IAllowReplies(address(0)));

    // The browser will be used too
    new ReplyStatusBrowser();

    vm.stopBroadcast();
  }
}
