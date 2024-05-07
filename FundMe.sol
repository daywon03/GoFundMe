
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    uint256 public minimumUsd = 3e18; // 3 * (10**18)
    address[] public funders;
    mapping (address funder => uint256 amountFunded) public addressToAmountFunded;// put in common the amount of money the senders sent with his address 
    address public owner;
    
    constructor(){
        owner = msg.sender;
    }

    function fund() public payable {
        //Allow users to send money
        //Required a minimum amount of money to send
        //msg.value value will be paste in the function getConversionrate
        require(msg.value.getConversionRate() >= minimumUsd, "didn't send enough money");//Library version        
        //require(getConversionRate(msg.value) >= minimumUsd, "didn't send enough money");//1e18 = 1ETH=1*10 puissance 18
        funders.push(msg.sender); // push in the list people who sends us money
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value; 
        // put in common the amount of money the senders sent with his address 
    }

    function withdraw() public onlyOwner{
        //Set l'index funder a 0
        //Tant que funderindex inférieur au total des éléments de la table funders
        //ajouter 1 a funderIndex
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex ++) 
        {
            address funder = funders[funderIndex]; //Get the funders at the funder Address set (funderIndex)
            addressToAmountFunded[funder] = 0;//Reset the amount of this funder
        }
        funders = new address[](0);

        (bool callSuccess, /*bytes memory dataReturned*/) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");

    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Must be owner");
        _;
    }
}
