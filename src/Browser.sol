// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Attr.sol";
import "./ItemSet.sol";

contract Browser {
  function properties(address item, address[] memory attrs) public view returns(Attr.Property[] memory out) {
    uint256 i;
    uint256 propertyCount;
    for(i = 0; i < attrs.length; i++) {
      propertyCount += Attr(attrs[i]).propertyCount();
    }
    out = new Attr.Property[](propertyCount);
    propertyCount = 0;
    for(i = 0; i < attrs.length; i++) {
      Attr attr = Attr(attrs[i]);
      Attr.Property[] memory curFetcher = attr.properties(item);
      for(uint j = 0; j < attr.propertyCount(); j++) {
        out[propertyCount + j] = curFetcher[j];
      }
      propertyCount += attr.propertyCount();
    }
  }

  function fetchItems(
    address itemSet,
    address[] memory attrs,
    address parent,
    uint startIndex,
    uint fetchCount,
    bool reverseScan
  ) external view returns(ItemSet.ItemsResponse memory out) {
    ItemSet fetcher = ItemSet(itemSet);
    out = fetcher.fetchItems(parent, startIndex, fetchCount, reverseScan);
    for(uint j = 0; j < out.items.length; j++) {
      Attr.Property[] memory otherProps = properties(out.items[j].item, attrs);
      ItemSet.ItemProperty[] memory combinedProps = new ItemSet.ItemProperty[](otherProps.length + out.items[j].props.length);
      uint index;
      for(uint k = 0; k < out.items[j].props.length; k++) {
        combinedProps[index++] = out.items[j].props[k];
      }
      for(uint k = 0; k < otherProps.length; k++) {
        combinedProps[index].key = otherProps[k].key;
        combinedProps[index].value = otherProps[k].value;
        combinedProps[index++].valueType = otherProps[k].valueType;
      }
      out.items[j].props = combinedProps;
    }
  }
}
