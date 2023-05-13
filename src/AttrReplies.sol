// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Attr.sol";
import "./ItemSet.sol";

contract AttrReplies is Attr, ItemSet {
  uint256 public override constant propertyCount = 2;
  int32 public constant minStatus = 0;

  mapping(address => address[]) public replies;
  mapping(address => mapping(address => int32)) public replyStatus;
  mapping(address => uint256) public replyCountLTZero;
  
  event ReplyStatusUpdated(address indexed item, address indexed reply, int32 oldStatus, int32 newStatus);
  event ReplyAdded(address indexed item, address indexed reply, uint256 indexed replyIndex);

  function addReply(address item, address reply) external {
    emit ReplyAdded(item, reply, replies[item].length);
    replies[item].push(reply);
  }

  function replyCount(address item) public view returns(uint256) {
    return replies[item].length;
  }

  function replyCountGTEZero(address item) public view returns(uint256) {
    return replies[item].length - replyCountLTZero[item];
  }

  struct ReplyStatus {
    address item;
    int32 status;
  }

  function setReplyStatus(address item, ReplyStatus[] memory newStatus) external onlyItemOwner(item) {
    if(newStatus.length > 0) {
      for(uint256 i = 0; i < newStatus.length; i++) {
        int32 oldVal = replyStatus[item][newStatus[i].item];
        int32 newVal = newStatus[i].status;
        if(oldVal == newVal) continue;
        emit ReplyStatusUpdated(item, newStatus[i].item, oldVal, newVal);
        replyStatus[item][newStatus[i].item] = newVal;

        bool changedSign = (oldVal > 0 && newVal < 0) || (oldVal < 0 && newVal > 0);
        if(changedSign) {
          if(newVal > 0) replyCountLTZero[item]--;
          else replyCountLTZero[item]++;
        }
      }
    }
  }

  function properties(address item) external override view returns(Property[] memory out) {
    out = new Property[](propertyCount);

    out[0].key = "replyCount";
    out[0].valueType = "uint256";
    out[0].value = abi.encodePacked(replyCount(item));
    out[1].key = "replyCountGTEZero";
    out[1].valueType = "uint256";
    out[1].value = abi.encodePacked(replyCountGTEZero(item));
  }

  function fetchItems(
    address parent,
    uint startIndex,
    uint fetchCount,
    bool reverseScan
  ) external override view returns(ItemsResponse memory) {
    if(replies[parent].length == 0) return ItemsResponse(new ItemDetails[](0), 0, 0);
    require(startIndex < replies[parent].length);
    if(startIndex + fetchCount >= replies[parent].length) {
      fetchCount = replies[parent].length - startIndex;
    }
    address[] memory selection = new address[](fetchCount);
    uint activeCount;
    uint i;
    uint replyIndex = startIndex;
    if(reverseScan) {
      replyIndex = replies[parent].length - 1 - startIndex;
    }
    while(true) {
      selection[i] = replies[parent][replyIndex];
      if(replyStatus[parent][selection[i]] >= minStatus) activeCount++;
      if(activeCount == fetchCount) break;
      if(reverseScan) {
        if(replyIndex == 0) break;
        replyIndex--;
      } else {
        if(replyIndex == replies[parent].length - 1) break;
        replyIndex++;
      }
      i++;
    }

    ItemDetails[] memory out = new ItemDetails[](activeCount);
    uint j;
    for(i=0; i<fetchCount; i++) {
      if(replyStatus[parent][selection[i]] >= minStatus) {
        ItemProperty[] memory props = new ItemProperty[](1);
        props[0].key = "status";
        props[0].valueType = "int32";
        props[0].value = abi.encodePacked(replyStatus[parent][selection[i]]);
        out[j++] = ItemDetails(selection[i], props);
      }
    }
    return ItemsResponse(out, replies[parent].length, replyIndex);
  }
}
