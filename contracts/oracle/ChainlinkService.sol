// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ChainlinkService {
    function getLatestPrice(address feedAddress)
        public
        view
        returns (
            int256,
            uint256,
            uint8
        )
    {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(feedAddress);
        (, int256 price, , uint256 timeStamp, ) = priceFeed.latestRoundData();
        uint8 decimal = priceFeed.decimals();
        return (price, timeStamp, decimal);
    }
}
