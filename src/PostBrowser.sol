// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./ReplyBrowser.sol";
import "./ReplyStatusBrowser.sol";
import "./browser/IFetch.sol";
import "./browser/IFetchReplies.sol";

contract PostBrowser {
  using EnumerableSet for EnumerableSet.AddressSet;
  EnumerableSet.AddressSet private fetchers;
  // Not an AddressSet because the order is important
  // The first matching replyFetcher does the job
  address[] public replyFetchers;

  struct ReplyDetails {
    address item;
    int32 status;
    IFetch.Property[] props;
    bytes4[] interfaces;
  }

  struct RepliesResponse {
    ReplyDetails[] items;
    uint totalCount;
    uint lastScanned;
  }

  // TODO add/remove fetchers after init
  constructor(address[] memory _fetchers, address[] memory _replyFetchers) {
    for(uint i = 0; i < _fetchers.length; i++) {
      fetchers.add(_fetchers[i]);
    }
    replyFetchers = _replyFetchers;
  }

  function listFetchers() external view returns(address[] memory) {
    return fetchers.values();
  }

  function properties(address item) public view returns(IFetch.Property[] memory out) {
    uint256 i;
    uint256 propertyCount;
    for(i = 0; i < fetchers.length(); i++) {
      propertyCount += IFetch(fetchers.at(i)).propertyCount();
    }
    out = new IFetch.Property[](propertyCount);
    propertyCount = 0;
    for(i = 0; i < fetchers.length(); i++) {
      IFetch fetcher = IFetch(fetchers.at(i));
      if(!IERC165(item).supportsInterface(fetcher.interfaceId())) continue;
      IFetch.Property[] memory curFetcher = fetcher.properties(item);
      for(uint j = 0; j < fetcher.propertyCount(); j++) {
        out[propertyCount + j] = curFetcher[j];
      }
      propertyCount += fetcher.propertyCount();
    }
  }

  function matchingInterfaces(address item) public view returns(bytes4[] memory out) {
    uint256 i;
    uint256 matchCount;
    for(i = 0; i < fetchers.length(); i++) {
      IFetch fetcher = IFetch(fetchers.at(i));
      if(!IERC165(item).supportsInterface(fetcher.interfaceId())) continue;
      matchCount++;
    }
    out = new bytes4[](matchCount);
    uint j;
    for(i = 0; i < fetchers.length(); i++) {
      IFetch fetcher = IFetch(fetchers.at(i));
      if(!IERC165(item).supportsInterface(fetcher.interfaceId())) continue;
      out[j++] = fetcher.interfaceId();
    }
  }

  function fetchReplies(
    address post,
    uint startIndex,
    uint fetchCount,
    bool reverseScan
  ) external view returns(IFetchReplies.RepliesResponse memory out) {
    for(uint i = 0; i < fetchers.length(); i++) {
      IFetchReplies fetcher = IFetchReplies(replyFetchers[i]);
      if(!IERC165(post).supportsInterface(fetcher.interfaceId())) continue;
      out = fetcher.fetchReplies(post, startIndex, fetchCount, reverseScan);
      for(uint j = 0; j < out.items.length; j++) {
        IFetch.Property[] memory otherProps = properties(out.items[j].item);
        IFetchReplies.Property[] memory combinedProps = new IFetchReplies.Property[](otherProps.length + out.items[j].props.length);
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
      return out;
    }
  }
}

