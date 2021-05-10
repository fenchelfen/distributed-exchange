// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract InnoDEX is Ownable {

  using SafeMath for uint256;

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
}

