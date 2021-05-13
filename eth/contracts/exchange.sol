// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract InnoDEX is Ownable {

  using SafeMath for uint256;

  Token token;
  Order[] bidOrders;
  Order[] askOrders;

  mapping(bytes32 => Order) orders;
  mapping(address => uint256) public tokenBalances;
  mapping(address => uint256) public etherBalances;

  struct Token {
          ERC20 tokenContract;
  }

  struct Order {
          address account;
          uint256 amount;
          uint arrayIdx;
          OrderType orderType;
          Ticker ticker;
          bool isValue; // used to verify that it's an initialized value 
  }

  enum OrderType { Bid, Ask }
  enum Ticker { ETH, SWOT }

  constructor(ERC20 tokenContract) {
          token.tokenContract = tokenContract;
  }

  function depositToken(uint amount) public payable {
          require(token.tokenContract.transferFrom(msg.sender, address(this), amount),
                  'Failed to transfer tokens to SCA');
          tokenBalances[msg.sender] = tokenBalances[msg.sender].add(amount);

          emit TokenDeposited(msg.sender, block.timestamp, token.tokenContract.symbol(), amount);
  }
  function depositEther() public payable {
          etherBalances[msg.sender] = etherBalances[msg.sender].add(msg.value);

          emit EtherDeposited(msg.sender, block.timestamp, token.tokenContract.symbol(), msg.value);
  }

  function tickerBidsExist(Ticker ticker) public view returns (bool) {
          for (uint i = 1; i < bidOrders.length; i++) {
                  if (bidOrders[i].ticker == ticker)
                          return true;
          }
          return false;
  }
  function tickerAsksExist(Ticker ticker) public view returns (bool) {
          for (uint i = 1; i < askOrders.length; i++) {
                  if (askOrders[i].ticker == ticker)
                          return true;
          }
          return false;
  }

  function getBestBid(Ticker ticker) public view returns (uint) {
          uint maxBidIdx = 0;
          for (uint i = 1; i < bidOrders.length; i++) {
                  if (askOrders[i].ticker != ticker)
                          continue;
                  if (bidOrders[i].amount > bidOrders[maxBidIdx].amount)
                          maxBidIdx = i;
          }
          return maxBidIdx;
  }
  function getBestAsk(Ticker ticker) public view returns (uint) {
          uint minAskIdx = 0;
          for (uint i = 1; i < askOrders.length; i++) {
                  if (askOrders[i].ticker != ticker)
                          continue;
                  if (askOrders[i].amount > askOrders[minAskIdx].amount)
                          minAskIdx = i;
          }
          return minAskIdx;
  }

  function placeBidOrder(uint256 amount, Ticker ticker) public {
          Order memory o = Order(msg.sender, amount, bidOrders.length, OrderType.Bid, ticker, true);
          bytes32 id = getOrderId(o);
          orders[id] = o;
          bidOrders.push(orders[id]);
  }

  function placeAskOrder(uint256 amount, Ticker ticker) public {
          Order memory o = Order(msg.sender, amount, askOrders.length, OrderType.Ask, ticker, true);
          bytes32 id = getOrderId(o);
          orders[id] = o;
          bidOrders.push(orders[id]);
  }

  function cancelBidOrder(uint256 amount, Ticker ticker) public {
          bytes32 id = getOrderId(Order(msg.sender, amount, 0, OrderType.Bid, ticker, true));
          Order storage o = orders[id];
          removeOrder(o);
  }
  function cancelAskOrder(uint256 amount, Ticker ticker) public {
          bytes32 id = getOrderId(Order(msg.sender, amount, 0, OrderType.Bid, ticker, true));
          Order storage o = orders[id];
          removeOrder(o);
  }
  function removeOrder(Order storage o) internal {
          require(o.isValue, 'Such order does not exist');
          if (OrderType.Bid == o.orderType) {
                  delete bidOrders[o.arrayIdx];
          } else {
                  delete askOrders[o.arrayIdx];
          }
          delete orders[getOrderId(o)];
  }

  function getOrderId(Order memory o) internal pure returns (bytes32) {
          return keccak256(abi.encode(o.account, o.amount, o.orderType, o.ticker));
  }

  function matchOrders() internal {
          uint bestETHBidIdx = getBestBid(Ticker.ETH);
          uint bestETHAskIdx = getBestAsk(Ticker.ETH);

          uint bestSWOTBidIdx = getBestBid(Ticker.SWOT);
          uint bestSWOTAskIdx = getBestAsk(Ticker.SWOT);

          // todo: check that bids are close enough
          if (!tickerBidsExist(Ticker.ETH) || !tickerAsksExist(Ticker.SWOT))
                  return;

          executeOrders(bidOrders[bestETHBidIdx], askOrders[bestETHAskIdx]);
          executeOrders(bidOrders[bestSWOTBidIdx], askOrders[bestSWOTAskIdx]);
  }
  function executeOrders(Order storage bid, Order storage ask) internal {
          require(bid.ticker == ask.ticker, 'Orders have different tickers');
          Ticker ticker = bid.ticker;

          if (!isSameBucket(bid.amount, ask.amount))
                  return;

          if (Ticker.ETH == ticker) {
                  // Bidder bought some SWOT for some ETH
                  etherBalances[bid.account] -= bid.amount;
                  tokenBalances[bid.account] += ask.amount;
                  // Asker bought some ETH for some SWOT
                  etherBalances[ask.account] += bid.amount;
                  tokenBalances[ask.account] -= ask.amount;
          }
          if (Ticker.SWOT == ticker) {
                  // Bidder bought some ETH for some SWOT
                  etherBalances[bid.account] += bid.amount;
                  tokenBalances[bid.account] -= ask.amount;
                  // Asker bought some SWOT for some ETH
                  etherBalances[ask.account] -= bid.amount;
                  tokenBalances[ask.account] += ask.amount;
          }

          emit OrderExecuted(bid.account, ask.account, ticker);

          removeOrder(bid);
          removeOrder(ask);
          // ask.account.transfer(bid.amount);
          // token.tokenContract.transferFrom(address(this), ask.account, amount);
  }
  function isSameBucket(uint256 a, uint256 b) public pure returns (bool) {
    uint256 max;
    uint256 min;

    if (a == b) {
      return true;
    }

    if (a > b) { max = a; min = b; }
    else { max = b; min = a; }

    // precision is up to 4 decimals
    uint256 t = (max - min) / 100;

    // if integer part is 0, then two amounts are close enough to be in the same bucket
    return (t == 0);
  }

  function getETHBalance() public view returns (uint256) {
          return etherBalances[msg.sender];
  }

  function getSWOTBalance() public view returns (uint256) {
          return tokenBalances[msg.sender];
  }

  event TokenDeposited(address indexed _initiator, uint _timestamp, string _tokenSymbol, uint _amount);
  event EtherDeposited(address indexed _initiator, uint _timestamp, string _tokenSymbol, uint _amount);

  event OrderExecuted(address indexed bidder, address indexed asker, Ticker ticker);
}

