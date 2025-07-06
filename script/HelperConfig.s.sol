//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.sol";
contract HelperConfig is Script {
    
        NetworkConfig public activeNetworkConfig;
        uint8 public constant DECIMALS = 8;
        int256 public constant INITIAL_PRICE = 2000e8; // 2000 USD in

        struct NetworkConfig {
            address priceFeed;
        }
        constructor() {
                if (block.chainid == 11155111) { // Sepolia
                    activeNetworkConfig = getSepoliaEthConfig(); // Sepolia ETH/USD Price Feed
                }
                else if (block.chainid == 80001) { // Mumbai
                    activeNetworkConfig = getMumbaiEthConfig(); // Mumbai ETH/USD Price Feed
                } 
                else {
                    activeNetworkConfig = getOrCreateAnvilEthConfig();
                }
            }

        function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
            NetworkConfig memory sepoliaConfig = NetworkConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // Sepolia ETH/USD Price Feed
            });
            return sepoliaConfig;
        }
        function getMumbaiEthConfig() public pure returns (NetworkConfig memory) {
            NetworkConfig memory mumbaiConfig = NetworkConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // Mumbai ETH/USD Price Feed
            });
            return mumbaiConfig;
        }
        function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
            if (activeNetworkConfig.priceFeed != address(0)) {
                return activeNetworkConfig; // Return existing config if available
            }

            vm.startBroadcast();
            MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_PRICE); // 2000 USD in 18 decimals

            vm.stopBroadcast();

            NetworkConfig memory anvilConfig = NetworkConfig({
                priceFeed: address(mockV3Aggregator) // Anvil ETH/USD Price Feed
            });

            return anvilConfig;
        }
}


