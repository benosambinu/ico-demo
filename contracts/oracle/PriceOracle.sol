// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ChainlinkService.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PriceOracle is ChainlinkService, Ownable {
    using SafeMath for uint256;

    //ETH feed address
    address public feedAddress;

    constructor(address _feedAddress) {
        feedAddress = _feedAddress;
    }

    function setETHFeed(address _feedAddress) external onlyOwner {
        feedAddress = _feedAddress;
    }

    function getETHPrice() public view returns (uint256) {
        (int256 price, , uint8 decimals) = getLatestPrice(feedAddress);

        if (decimals < 18) {
            return (uint256(price)).mul(10**uint256(18 - decimals));
        } else if (decimals > 18) {
            return (uint256(price)).div(uint256(decimals - 18));
        } else {
            return uint256(price);
        }
    }
}
