// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./token/Token.sol";
import "./oracle/PriceOracle.sol";

contract ICO is Ownable, ReentrancyGuard {
    using SafeERC20 for Token;
    using SafeMath for uint256;

    Token public token; //Address of the Token.
    PriceOracle public oracle; //Address of the ETH/USD price oracle.

    enum ICOStage {
        PreSale,
        SeedSale,
        FinalSale
    }

    ICOStage public stage = ICOStage.PreSale;

    address payable public wallet; //Address of the reciever of the Funds.
    uint256 public weiRaised; //Amount of WEI raised in the ICO.
    uint256 public totalTokensPurchased; //Total amount of tokens that have been purchased.

    uint256 public maxTokens = 100000000000000000000000000; //100 million
    uint256 public preSaleRate = 10000000000000000; //0.01
    uint256 public preSaleTokens = 30000000000000000000000000; //30 million
    uint256 public seedSaleRate = 20000000000000000; //0.02
    uint256 public seedSaleTokens = 50000000000000000000000000; //50 million
    uint256 public finalSaleRate;

    //Events
    event TokensPurchased(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );
    event EthRefunded(string text);

    /**
     * @dev Executed when the ICO contract is deployed.
     * @param _name Name for the Token.
     * @param _symbol Symbol for the token.
     * @param _amount Total Supply for the token.
     * @param _wallet Address of the wallet to forward funds to.
     * @param _oracle Address of the ETH/USD price oracle.
     */
    constructor(
        string memory _symbol,
        string memory _name,
        uint256 _amount,
        address payable _wallet,
        PriceOracle _oracle
    ) {
        token = new Token(_symbol, _name, _amount);
        wallet = _wallet;
        oracle = _oracle;
    }

    /**
     * @dev Function to set the stage of ICO.
     * @param value Index value for the Stage of ICO.
     */
    function setICOStage(uint256 value) public onlyOwner {
        ICOStage _stage;

        if (uint256(ICOStage.PreSale) == value) {
            _stage = ICOStage.PreSale;
        } else if (uint256(ICOStage.SeedSale) == value) {
            _stage = ICOStage.SeedSale;
        } else if (uint256(ICOStage.FinalSale) == value) {
            _stage = ICOStage.FinalSale;
        }

        stage = _stage;
    }

    /**
     * @dev Function to set Rate of ICO token for Final Sale.
     * @param _finalSaleRate Rate of token in Final sale.
     */
    function setFinalSaleRate(uint256 _finalSaleRate) public onlyOwner {
        finalSaleRate = _finalSaleRate;
    }

    /**
     * @dev Validation of an incoming purchase.
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount)
        internal
        view
    {
        require(
            beneficiary != address(0),
            "ICO: beneficiary is the zero address"
        );
        require(weiAmount != 0, "ICO: weiAmount is 0");
        this;
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    /**
     * @dev Executed when a purchase has been validated and is ready to be executed.
     * @param beneficiary Address receiving the tokens
     * @param tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address beneficiary, uint256 tokenAmount)
        internal
    {
        token.safeTransfer(beneficiary, tokenAmount);
    }

    /**
     * @dev Function containing logic for how ether is converted to tokens.
     * @param weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 weiAmount)
        internal
        view
        returns (uint256)
    {
        uint256 ethToUSD = oracle.getETHPrice();
        uint256 depositNAV = ethToUSD.mul(weiAmount);

        if (stage == ICOStage.PreSale) return depositNAV.div(preSaleRate);
        if (stage == ICOStage.SeedSale) return depositNAV.div(seedSaleRate);
        if (stage == ICOStage.FinalSale) return depositNAV.div(finalSaleRate);
        return 0;
    }

    /**
     * @dev Function to purchase tokens.
     * @param beneficiary Recipient of the token purchase
     */
    function buyTokens(address beneficiary) public payable nonReentrant {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        uint256 tokens = _getTokenAmount(weiAmount);

        if (
            (stage == ICOStage.PreSale) &&
            (totalTokensPurchased + tokens > preSaleTokens)
        ) {
            payable(msg.sender).transfer(msg.value); // Refund them
            EthRefunded("Pre Sale Limit Hit");
            return;
        } else if (
            (stage == ICOStage.SeedSale) &&
            (totalTokensPurchased + tokens > preSaleTokens + seedSaleTokens)
        ) {
            payable(msg.sender).transfer(msg.value); // Refund them
            EthRefunded("Seed Sale Limit Hit");
            return;
        } else if (
            (stage == ICOStage.FinalSale) &&
            (totalTokensPurchased + tokens > maxTokens)
        ) {
            payable(msg.sender).transfer(msg.value); // Refund them
            EthRefunded("Final Sale Limit Hit");
            return;
        }

        weiRaised = weiRaised.add(weiAmount);
        totalTokensPurchased = totalTokensPurchased.add(tokens);

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        _forwardFunds();
    }

    /**
     * @dev Fallback function. if provided gas is 2300 it would revert, use buyTokens function instead.
     */
    fallback() external payable {
        buyTokens(_msgSender());
    }
}
