const InnoDEX = artifacts.require("InnoDEX");

contract('InnoDEX', (accounts) => {
  it('Test', async () => {
    var dex = await InnoDEX.deployed();
    await debug(dex.getTokenContract());
  });
});

