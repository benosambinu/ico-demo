const PriceOracle = artifacts.require("PriceOracle");
const ICO = artifacts.require("ICO");

module.exports = async (deployer, network, accounts) => {

    //Deploy Price Oracle
    // await deployer.deploy(PriceOracle, "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419"); //Mainnet ETH/USD Chainlink Feed Address
    await deployer.deploy(PriceOracle, "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e"); //Rinkeby ETH/USD Chainlink Feed Address
    const priceOracle = await PriceOracle.deployed();

    //Deploy ICO
    await deployer.deploy(ICO, "ITKN", "ICOToken", "100000000000000000000000000", accounts[1], priceOracle.address);
};
