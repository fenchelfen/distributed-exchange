// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract InnoDEX is Ownable {

  using SafeMath for uint256;

  Token token;

  mapping(address => uint256) public tokenBalances;

  constructor(ERC20 tokenContract) {
    token.tokenContract = tokenContract;
  }

  struct Offer {
    address account;
    uint256 amount;
  }

  struct OrderBook {
    mapping(uint => Offer) chart;
    // uint 
  }

  struct Token {
    ERC20 tokenContract;    
    OrderBook bidsOrderBook;
    OrderBook asksOrderBook;
  }

  function getTokenContract() public view returns (ERC20) {
    return token.tokenContract;
  }

  function depositEther(uint amount) public payable returns (uint256) {
    require(token.tokenContract.transferFrom(msg.sender, address(this), amount), 'Failed to transfer tokens to SCA');

    tokenBalances[msg.sender] = tokenBalances[msg.sender].add(amount);

    emit TokenDeposited(msg.sender, block.timestamp, token.tokenContract.symbol(), amount);
    return msg.value;
  }

  function placeBidLimitOrder() public {
  }

  function placeAskLimitOrder() public {
  }

  event TokenDeposited(address indexed _initiator, uint _timestamp, string _tokenSymbol, uint _amount);

}

