// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract InnoDEX is Ownable {

  using SafeMath for uint256;

  Token token;

  constructor(IERC20 tokenContract) {
    token.tokenContract = tokenContract;
  }

  struct Offer {
    address account;
    uint256 amount;
  }

  struct OrderBook {
    mapping(uint => Offer) chart;
  }

  struct Token {
    IERC20 tokenContract;    
    OrderBook bidsOrderBook;
    OrderBook asksOrderBook;
  }

  function getTokenContract() public view returns (IERC20) {
    return token.tokenContract;
  }

  function placeBidLimitOrder() public {
  }

  function placeAskLimitOrder() public {
  }
}

