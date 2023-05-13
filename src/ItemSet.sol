// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract ItemSet {
  struct ItemProperty {
    string key;
    bytes value;
    string valueType;
  }

  struct ItemDetails {
    address item;
    ItemProperty[] props;
  }

  struct ItemsResponse {
    ItemDetails[] items;
    uint totalCount;
    uint lastScanned;
  }

  function fetchItems(
    address parent,
    uint startIndex,
    uint fetchCount,
    bool reverseScan
  ) external virtual view returns(ItemsResponse memory);
}

