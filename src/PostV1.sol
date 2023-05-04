// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "./IPost.sol";

// This is an example of a type of post contract
// where the owner can decide how to moderate the replies
contract PostV1 is Ownable, ERC165 {
  string public message;
  uint256 public created;

  mapping(address => int32) public replyStatus;
  address[] public replies;

  event ReplyAdded(address indexed item, uint256 indexed replyIndex);
  event ReplyStatusUpdated(address indexed item, int32 oldStatus, int32 newStatus);
  event MessageChanged(string oldValue, string newValue);

  constructor(string memory _message, address _owner) {
    message = _message;
    created = block.timestamp;
    _transferOwnership(_owner);
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IPost).interfaceId || super.supportsInterface(interfaceId);
  }

  function editMessage(string memory newValue) external onlyOwner {
    emit MessageChanged(message, newValue);
    message = newValue;
  }

  // TODO Automod -- Require coinpassport verification?
  // TODO Whitelist factories which can reply?
  function addReply(IPost reply) external {
    require(replyStatus[address(reply)] == 0); // Disallow duplicates
    require(bytes(reply.message()).length > 5);
    emit ReplyAdded(address(reply), replies.length);
    replies.push(address(reply));
    replyStatus[address(reply)] = 1;
  }

  function replyCount() external view returns(uint256) {
    return replies.length;
  }

  struct ReplyStatus {
    address item;
    int32 status;
  }

  function setReplyStatus(ReplyStatus[] memory newStatus) external onlyOwner {
    if(newStatus.length > 0) {
      for(uint256 i = 0; i < newStatus.length; i++) {
        require(newStatus[i].status != 0);
        emit ReplyStatusUpdated(newStatus[i].item, replyStatus[newStatus[i].item], newStatus[i].status);
        replyStatus[newStatus[i].item] = newStatus[i].status;
      }
    }
  }

  struct ReplyDetails {
    address owner;
    address item;
    uint256 created;
    string message;
    int32 status;
  }

  struct RepliesResponse {
    ReplyDetails[] items;
    uint totalCount;
    uint lastScanned;
  }

  // Sorting must happen on the client
  function fetchReplies(
    int32 minStatus,
    uint startIndex,
    uint fetchCount,
    bool reverseScan
  ) external view returns(RepliesResponse memory) {
    if(replies.length == 0) return RepliesResponse(new ReplyDetails[](0), 0, 0);
    require(startIndex < replies.length);
    if(startIndex + fetchCount >= replies.length) {
      fetchCount = replies.length - startIndex;
    }
    address[] memory selection = new address[](fetchCount);
    uint activeCount;
    uint i;
    uint replyIndex = startIndex;
    if(reverseScan && startIndex == 0) {
      replyIndex = replies.length - 1;
    }
    while(activeCount < fetchCount && replyIndex < replies.length) {
      selection[i] = replies[replyIndex];
      if(replyStatus[selection[i]] >= minStatus) activeCount++;
      if(reverseScan) {
        if(replyIndex == 0 || activeCount == fetchCount) break;
        replyIndex--;
      } else {
        replyIndex++;
      }
      i++;
    }

    ReplyDetails[] memory out = new ReplyDetails[](activeCount);
    uint j;
    for(i=0; i<fetchCount; i++) {
      if(replyStatus[selection[i]] >= minStatus) {
        PostV1 reply = PostV1(selection[i]);
        out[j++] = ReplyDetails(
          reply.owner(),
          selection[i],
          reply.created(),
          reply.message(),
          replyStatus[selection[i]]
        );
      }
    }
    return RepliesResponse(out, replies.length, replyIndex);
  }
}

contract PostV1Factory {
  event NewRootPost(address indexed post);

  function createNew(
    string memory message,
    PostV1 parent
  ) external returns(PostV1 created) {
    created = new PostV1(message, msg.sender);
    if(address(parent) != address(0)) {
      parent.addReply(IPost(address(created)));
    } else {
      emit NewRootPost(address(created));
    }
  }
}
