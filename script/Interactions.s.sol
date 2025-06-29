//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DevopsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script{
    uint256 constant FUND_AMOUNT = 0.1 ether;

   function fundFundMe (address mostRecentDeployment) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployment)).fund{value: FUND_AMOUNT}();
        vm.stopBroadcast();
        console.log("Funded Fundme with %s", FUND_AMOUNT);
    }
   }
   function run() external {

    address mostRecentDeployment = DevopsTools.get_most_recent_deployment(
        "FundMe",
        block.chainid
    );
    FundFundMe(mostRecentDeployment);
    

       
   }


contract WithdrawFundMe is Script {

}