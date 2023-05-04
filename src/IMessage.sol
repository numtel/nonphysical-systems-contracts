// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IMessage is IERC165 {
  function message() external view returns(string memory);
  function created() external view returns(uint256);
}

