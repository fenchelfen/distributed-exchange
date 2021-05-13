swot = await SWOT.at("0x137B143A9c71dE7eF8d0c697f288FBB5c4B4c606")
dex = await InnoDEX.at("0x12308a23bd066eb0bd7701a5f48d39c0ecb9c566")
swot.increaseAllowance(dex.address, 20)
dex.depositToken(12)
dex.getSWOTBalance.c
