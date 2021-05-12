// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./utils/SwotQueue.sol";
import "./utils/SwotOrderBook.sol";

contract InnoDEX is Ownable, SwotQueue, SwotOrderBook {

  using SafeMath for uint256;

  Token token;

  mapping(address => uint256) public tokenBalances;

  constructor(ERC20 tokenContract) {
    token.tokenContract = tokenContract;

    pushToQueue(token.bidsOrderBook.root.orders, 1337, msg.sender, OrderType.Bid);
    pushToQueue(token.asksOrderBook.root.orders, 0, msg.sender, OrderType.Ask);
  }

  uint public constant bucketStart = 100;
  uint public constant bucketEnd = 999;
  mapping(uint256 => uint256) buckets;

  struct Token {
    ERC20 tokenContract;    
    OrderBook bidsOrderBook;
    OrderBook asksOrderBook;
    uint256 currentSellPrice;
  }

  function getTokenContract() public view returns (ERC20) {
    return token.tokenContract;
  }
 
  /* START OrderBookAPI */

  function sayHello() public view returns (string memory) {
    return "Hi There";
  }
  
  function isSameBucket(uint256 a, uint256 b) public returns (bool) {
    uint256 max;
    uint256 min;

    if (a == b) {
      return true;
    }

    if (a > b) { max = a; min = b; }
    else { max = b; min = a; }

    // precision is up to 4 decimals
    uint256 t = (max - min) / 10000;

    // if integer part is 0, then two amounts are close enough to be in the same bucket
    return (t == 0);
  }

  event OrderInserted(address indexed _initiator, uint _timestamp, uint _amount);
  event OrderCreated(address indexed _initiator, uint _amount, OrderType _orderType);
  event OrderFound(address indexed _initiator, uint _index, uint _amount, OrderType _orderType);
  event FlagA();
  event FlagB();
  event FlagC();
  event FlagD();

  function traverseTree(OrderType orderType) public {
    OrderBook storage book;

    if (orderType == OrderType.Bid) { book = token.bidsOrderBook; }
    else { book = token.asksOrderBook; }

    OrderBookNode storage currentNode = book.root;

    dfs(currentNode, book);
  }

  function dfs(OrderBookNode storage currentNode, OrderBook storage book) internal {
    while(currentNode.orders.data.length > currentNode.orders.cursorPosition) {
      Order storage o = popFromQueue(currentNode.orders);
      emit OrderFound(o.account, currentNode.idx, o.amount, o.orderType);
    }

    if (currentNode.left != 0)
       dfs(getNode(book, currentNode.left), book);

    if (currentNode.right != 0)
       dfs(getNode(book, currentNode.right), book);
  }

  function insertOrder(uint256 amount, OrderType orderType) public {
    // todo: require that enough money is deposited
    Order memory order = Order(msg.sender, amount, orderType);
    OrderBookNode storage currentNode;
    OrderBook storage book;

    if (orderType == OrderType.Bid) { book = token.bidsOrderBook; }
    else { book = token.asksOrderBook; }

    currentNode = book.root;

    if (isSameBucket(order.amount, pickFromQueue(currentNode.orders).amount)) {
      // todo: push into the root bucket queue
      pushToQueue(currentNode.orders, order.amount, order.account, order.orderType);
      Order storage o = pickFromQueue(currentNode.orders);
      emit OrderCreated(o.account, o.amount, o.orderType);
    }

    while (true) {
      if (isSameBucket(order.amount, pickFromQueue(currentNode.orders).amount)) {
        pushToQueue(currentNode.orders, order.amount, order.account, order.orderType);
        break;
      }

      if (order.amount > pickFromQueue(currentNode.orders).amount) {
        // if the right node does not exist
        if (currentNode.right == 0) {
          currentNode = addRight(book, currentNode);
        } else {
          currentNode = getNode(book, currentNode.right);
        }
        pushToQueue(currentNode.orders, order.amount, order.account, order.orderType);
        break;
      } else {
        // if the left node does not exist 
        if (currentNode.left == 0) {
          currentNode = addLeft(book, currentNode);
        } else {
          currentNode = getNode(book, currentNode.left);
        }
        pushToQueue(currentNode.orders, order.amount, order.account, order.orderType);
        break;
      }
    }

    emit OrderInserted(msg.sender, block.timestamp, amount);
    emit OrderInserted(msg.sender, block.timestamp, order.amount);
  }
  
  function executeOrder() internal {
  }

  function cancelOrder() internal {
  }

  function getBestBid() internal {
  }

  /* END   OrderBookAPI */

  function placeBidLimitOrder() public {
  }

  function placeAskLimitOrder() public {
  }

  function cancelLimitOrder() public {
  }

  function depositEther(uint amount) public payable {
    require(token.tokenContract.transferFrom(msg.sender, address(this), amount), 'Failed to transfer tokens to SCA');

    tokenBalances[msg.sender] = tokenBalances[msg.sender].add(amount);

    emit TokenDeposited(msg.sender, block.timestamp, token.tokenContract.symbol(), amount);
  }
 

  /* START view functions */

  function getBucketAt(uint256 idx) public returns (uint256) {
    return buckets[idx];
  } 

  function getBid(uint256 bucket) public view returns (uint256) {
    // Traverse the tree and find out how many orders are in this bucket 
    return 77;
  }

  function getAsk(uint256 bucket) public view returns (uint256) {
    return 128;
  }

  /* END   view functions */

  event TokenDeposited(address indexed _initiator, uint _timestamp, string _tokenSymbol, uint _amount);
}

