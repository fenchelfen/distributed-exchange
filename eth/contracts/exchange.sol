// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SwotQueue
{
    struct Queue {
        bytes32[] data;
        uint front;
        uint back;
        mapping(bytes32 => Order) hashToOrder;
    }

    struct Order {
      address account;
      uint256 amount;
    }

    function getOrderId(Order memory order) internal pure returns (bytes32)
    {
      return keccak256(abi.encode(order.account, order.amount));
    }
    /// @dev the number of elements stored in the queue.
    function length(Queue storage q) internal returns (uint) {
        return q.back - q.front;
    }
    /// @dev the number of elements this queue can hold
    function capacity(Queue storage q) internal returns (uint) {
        return q.data.length - 1;
    }
    /// @dev push a new element to the back of the queue
    function push(Queue storage q, bytes32 data) internal
    {
        if ((q.back + 1) % q.data.length == q.front)
            return; // throw;
        q.data[q.back] = data;
        q.back = (q.back + 1) % q.data.length;
    }
    /// @dev remove and return the element at the front of the queue
    function pop(Queue storage q) internal returns (bytes32 r)
    {
        if (q.back == q.front)
            revert(); // throw;
        r = q.data[q.front];
        delete q.data[q.front];
        q.front = (q.front + 1) % q.data.length;
    }
    /// @dev pick a value at the front of the queue 
    function pick(Queue storage q) internal returns (bytes32 r)
    {
        if (q.back == q.front)
            revert(); // throw;
        return q.data[q.front];
    }
    function pushToQueue(Queue storage q, Order memory order) internal {
        bytes32 orderId = getOrderId(order);
        q.hashToOrder[orderId] = order;
        push(q, orderId);
    }
    function pickFromQueue(Queue storage q) internal returns (Order memory) {
        bytes32 orderId = pick(q);
        return q.hashToOrder[orderId];
    }
    function popFromQueue(Queue storage q) internal returns (Order memory order) {
        bytes32 orderId = pop(q);
        order = q.hashToOrder[orderId];
        q.hashToOrder[orderId] = Order(address(0), 0);
    }
}

contract SwotOrderBook is SwotQueue 
{
  struct OrderBook {
    OrderBookNode root;
    OrderBookNode[] nodes;
  }

  struct OrderBookNode {
    uint256 left;
    uint256 right;
    uint256 parent;

    uint256 maxAmount; 
    uint256 minAmount;
    uint256 totalAmount;

    Queue orders; // list of order identifiers (idx)
    mapping(bytes32 => Order) hashToOrder; 
  }
  function getNode(OrderBook storage book, uint256 id) internal returns (OrderBookNode storage) {
    return book.nodes[id];
  }
}

contract InnoDEX is Ownable, SwotQueue, SwotOrderBook {

  using SafeMath for uint256;

  Token token;

  mapping(address => uint256) public tokenBalances;

  constructor(ERC20 tokenContract) {
    token.tokenContract = tokenContract;

    Order memory firstOrder = Order(msg.sender, 1337);
    pushToQueue(token.bidsOrderBook.root.orders, firstOrder);
  }

  enum OrderType { Bid, Ask }

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

  function insertOrder(uint256 amount, OrderType orderType) public {
    Order memory order;
    order.account = msg.sender;
    order.amount = amount;

    OrderBookNode storage currentNode = token.bidsOrderBook.root;
    
    if (orderType == OrderType.Bid) { currentNode = token.bidsOrderBook.root; }
    else { currentNode = token.asksOrderBook.root; }


    if (isSameBucket(order.amount, pickFromQueue(currentNode.orders).amount)) {
      // todo: push into the root bucket queue
    }

    while (true) {
      if (isSameBucket(order.amount, pickFromQueue(currentNode.orders).amount)) {
        // todo: push into this node bucket queue
        break;
      }

      if (order.amount > pickFromQueue(currentNode.orders).amount) {
        // todo: go to the right
      } else {
        // todo: go to the left
      }
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

