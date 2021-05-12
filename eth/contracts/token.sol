// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract HELLO {

  string public name;

  constructor(string memory _name) {
    name = _name; 
  }

  function getName() public view returns (string memory) {
    return name;
  }

  function sayHello() public view returns (string memory) {
    return "Hi There";
  }
}

contract SWOT is ERC20 {

  constructor (string memory name, string memory symbol) ERC20(name, symbol) {
    _mint(msg.sender, 9999);
  }
}
