// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;


    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, SEND_VALUE); // Give USER 0.1 ETH

    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund(); // No ETH sent, should revert
    }
    function testFundUpdatesDataStructure() public payable {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}(); // Send 10 ETH, should succeed
        uint256 fundedAmount = fundMe.getAddressToAmountFunded(USER);
        assertEq(fundedAmount, SEND_VALUE); // Check if the amount funded is correct
    }

    function testAddFunderToArray() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}(); // Send 10 ETH, should succeed
        address funder = fundMe.getFunder(0); // Get the first funder
        assertEq(funder, USER); // Check if the first funder is USER
    }

    modifier funded() { //if there are many user we can use this modifier to fund the contract
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}(); // Send 10 ETH, should succeed
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded{
         // USER funds the contract
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw(); // USER tries to withdraw, should revert
        
    }
    function testWithdrawWithSingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;


        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); // Owner withdraws funds 

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd)* tx.gasprice;
        console.log(gasUsed);
        // Calculate gas used in the transaction
        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
        assertEq(endingFundMeBalance, 0);
    }

    function testWithdrawWithMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // Start from 1 to avoid USER
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank new address
            // Give each funder SEND_VALUE amount of ETH vm.deal
            // fund the contract fundMe.fund{value: SEND_VALUE}();
            hoax(address(i), SEND_VALUE);//hoax- creates a new address and sends SEND_VALUE to it
            fundMe.fund{value: SEND_VALUE}(); // Each funder funds the contract


        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // Act
        vm.startPrank(fundMe.getOwner());// here we are using the owner address to withdraw
        fundMe.withdraw(); // Owner withdraws funds
        vm.stopPrank();//here we stop the prank so that we can use the owner address again
        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        
    }



}
