// migrations/2_deploy.js
// SPDX-License-Identifier: MIT
const swot = artifacts.require("SWOT");
const exchange = artifacts.require("InnoDEX");
const hello = artifacts.require("HELLO");

const tokenSettings = {
  name: "Street Workout Token",
  symbol: "SWOT"
}

module.exports = function(deployer) {
  deployer.deploy(swot, tokenSettings.name, tokenSettings.symbol).then(function() {
      deployer.deploy(exchange, swot.address);
  });
  deployer.deploy(hello, 'something');
};

