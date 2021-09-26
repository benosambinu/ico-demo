const PriceOracle = artifacts.require("PriceOracle");
const ICO = artifacts.require("ICO");
const Token = artifacts.require("Token");
const BN = require("bn.js")

contract('ICO', function (accounts) {
    let priceOracle;

    beforeEach(async function () {
        priceOracle = await PriceOracle.new("0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419");
        await ICO.new("ITKN", "ICOToken", "100000000000000000000000000", accounts[1], priceOracle.address)
    });

    it('should deploy the token and store the address', function (done) {
        ICO.deployed().then(async function (instance) {
            const token = await instance.token.call();
            assert(token, 'Token address couldn\'t be stored');
            done();
        });
    });

    it('should set stage to PreSale', function (done) {
        ICO.deployed().then(async function (instance) {
            await instance.setICOStage(0);
            const stage = await instance.stage.call();
            assert.equal(stage.toNumber(), 0, 'The stage couldn\'t be set to PreSale');
            done();
        });
    });

    it('Buying Tokens in Pre Stage ICO', function (done) {
        ICO.deployed().then(async function (instance) {
            const tokenAddress = await instance.token.call();
            const token = await Token.at(tokenAddress);
            const ethToUSD = await priceOracle.getETHPrice();
            const rate = await instance.preSaleRate();
            const deposit = new BN("1000000000000000000")
            const expected = (deposit.mul(ethToUSD)).div(rate);
            const tokenBalanceBefore = await token.balanceOf(accounts[2])
            await instance.buyTokens(accounts[2], { from: accounts[2], value: web3.utils.toWei("1", "ether") });
            const tokenBalanceAfter = await token.balanceOf(accounts[2])
            assert.equal(expected.toString(), (tokenBalanceAfter.sub(tokenBalanceBefore)).toString(), "Tokens to be bought calculated incorrectly")
            done();
        });
    });

    it('should transfer the ETH to wallet immediately', function (done) {
        ICO.deployed().then(async function (instance) {
            let balanceOfBeneficiary = await web3.eth.getBalance(accounts[1]);
            balanceOfBeneficiary = Number(balanceOfBeneficiary.toString(10));

            await instance.buyTokens(accounts[2], { from: accounts[2], value: web3.utils.toWei("2", "ether") });

            let newBalanceOfBeneficiary = await web3.eth.getBalance(accounts[1]);
            newBalanceOfBeneficiary = Number(newBalanceOfBeneficiary.toString(10));

            assert.equal(newBalanceOfBeneficiary, balanceOfBeneficiary + 2000000000000000000, 'ETH couldn\'t be transferred to the beneficiary');
            done();
        });
    });

    it('should set variable `weiRaised` correctly', function (done) {
        ICO.deployed().then(async function (instance) {
            let amount = (await instance.weiRaised()).toString();
            assert.equal(amount, web3.utils.toWei("3", "ether"), 'Total ETH raised in ICO was not calculated correctly');
            done();
        });
    });

    it('should set stage to SeedSale', function (done) {
        ICO.deployed().then(async function (instance) {
            await instance.setICOStage(1);
            const stage = await instance.stage.call();
            assert.equal(stage.toNumber(), 1, 'The stage couldn\'t be set to ICO');
            done();
        });
    });

    it('Buying Tokens in Seed Stage ICO', function (done) {
        ICO.deployed().then(async function (instance) {
            const tokenAddress = await instance.token.call();
            const token = await Token.at(tokenAddress);
            const ethToUSD = await priceOracle.getETHPrice();
            const rate = await instance.seedSaleRate();
            const deposit = new BN("1000000000000000000")
            const expected = (deposit.mul(ethToUSD)).div(rate);
            const tokenBalanceBefore = await token.balanceOf(accounts[2])
            await instance.buyTokens(accounts[2], { from: accounts[2], value: web3.utils.toWei("1", "ether") });
            const tokenBalanceAfter = await token.balanceOf(accounts[2])
            assert.equal(expected.toString(), (tokenBalanceAfter.sub(tokenBalanceBefore)).toString(), "Tokens to be bought calculated incorrectly")
            done();
        });
    });
    it('should set stage to FinalSale', function (done) {
        ICO.deployed().then(async function (instance) {
            await instance.setICOStage(2);
            const stage = await instance.stage.call();
            assert.equal(stage.toNumber(), 2, 'The stage couldn\'t be set to ICO');
            await instance.setFinalSaleRate("50000000000000000");
            const finalRate = await instance.finalSaleRate.call();
            assert.equal(finalRate.toString(), "50000000000000000", 'The final rate couldn\'t be set to ICO');
            done();
        });
    });

    it('Buying Tokens in Final Stage ICO', function (done) {
        ICO.deployed().then(async function (instance) {
            const tokenAddress = await instance.token.call();
            const token = await Token.at(tokenAddress);
            const ethToUSD = await priceOracle.getETHPrice();
            const rate = await instance.finalSaleRate();
            const deposit = new BN("1000000000000000000")
            const expected = (deposit.mul(ethToUSD)).div(rate);
            const tokenBalanceBefore = await token.balanceOf(accounts[2])
            await instance.buyTokens(accounts[2], { from: accounts[2], value: web3.utils.toWei("1", "ether") });
            const tokenBalanceAfter = await token.balanceOf(accounts[2])
            assert.equal(expected.toString(), (tokenBalanceAfter.sub(tokenBalanceBefore)).toString(), "Tokens to be bought calculated incorrectly")
            done();
        });
    });
});
