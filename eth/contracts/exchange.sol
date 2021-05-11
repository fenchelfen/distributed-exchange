// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Queue
{
    struct _Queue {
        uint[] data;
        uint front;
        uint back;
    }
    /// @dev the number of elements stored in the queue.
    function length(_Queue storage q) view internal returns (uint) {
        return q.back - q.front;
    }
    /// @dev the number of elements this queue can hold
    function capacity(_Queue storage q) view internal returns (uint) {
        return q.data.length - 1;
    }
    /// @dev push a new element to the back of the queue
    function push(_Queue storage q, uint data) internal
    {
        if ((q.back + 1) % q.data.length == q.front)
            return; // throw;
        q.data[q.back] = data;
        q.back = (q.back + 1) % q.data.length;
    }
    /// @dev remove and return the element at the front of the queue
    function pop(_Queue storage q) internal returns (uint r)
    {
        if (q.back == q.front)
            revert(); // throw;
        r = q.data[q.front];
        delete q.data[q.front];
        q.front = (q.front + 1) % q.data.length;
    }
}

contract InnoDEX is Ownable, Queue {

  using SafeMath for uint256;

  Token token;
  OrderBook book;

  mapping(address => uint256) public tokenBalances;

  constructor(ERC20 tokenContract) {
    token.tokenContract = tokenContract;
    // token.currentSellPrice = tokenContract.initialPrice;
  }

  struct Order {
    address account;
    uint256 amount;
  }

  enum OrderType { Bid, Ask }

  struct OrderBook {
    OrderBookNode root;
  }

  struct OrderBookNode {
    Queue orders;
    OrderBookNode[] left;
    OrderBookNode[] right;
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

  function depositEther(uint amount) public payable returns (uint256) {
    require(token.tokenContract.transferFrom(msg.sender, address(this), amount), 'Failed to transfer tokens to SCA');

    tokenBalances[msg.sender] = tokenBalances[msg.sender].add(amount);

    emit TokenDeposited(msg.sender, block.timestamp, token.tokenContract.symbol(), amount);
  }
  
  /* START OrderBookAPI */

  function sayHello() public view returns (string memory) {
    return "Hi There";
  }

  function isSameBucket(uint256 a, uint256 b) public returns (bool, uint256, uint256) {
    uint256 max;
    uint256 min;

    // if (a == b) {
    //   return true;
    // }

    if (a > b) { max = a; min = b; }
    else { max = b; min = a; }

    // precision is up to 4 decimals
    uint256 t = (max - min) / 10000;

    // if integer part is 0, then two amounts are close enough to be in the same bucket
    return (t == 0, max - min, max - min / 10000);
  }

  function insertOrder(uint256 amount, OrderType orderType) public view returns (string memory) {
    Order memory order;
    order.account = msg.sender;
    order.amount = amount;
    
    OrderBookNode memory currentNode = book.root;
    while (true) {
    }
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
