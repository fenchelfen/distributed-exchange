// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SwotQueue.sol";

contract SwotOrderBook is SwotQueue 
{
  struct OrderBook {
    OrderBookNode root;
    OrderBookNode[] nodes;
    uint256 maxIndex;
  }

  struct OrderBookNode {
    uint256 left;
    uint256 right;
    uint256 parent;
    uint256 idx; // node's id in the list 

    uint256 maxAmount; 
    uint256 minAmount;
    uint256 totalAmount;

    Queue orders; // list of order identifiers (idx)
    mapping(bytes32 => Order) hashToOrder; 
  }
  function getNode(OrderBook storage book, uint256 id) internal returns (OrderBookNode storage) {
    return book.nodes[id];
  }
  function addRight(OrderBook storage book, OrderBookNode storage node, OrderBookNode storage newNode) internal {
    book.maxIndex = book.maxIndex + 1;
    node.right = book.maxIndex;
    newNode.idx = book.maxIndex;
    newNode.parent = node.idx;
    book.nodes[node.right] = newNode;
  }
  function addLeft(OrderBook storage book, OrderBookNode storage node, OrderBookNode storage newNode) internal {
    book.maxIndex = book.maxIndex + 1;
    node.left = book.maxIndex;
    newNode.idx = book.maxIndex;
    newNode.parent = node.idx;
    book.nodes[node.left] = newNode;
  }
}

