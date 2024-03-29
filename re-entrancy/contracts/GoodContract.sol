// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract GoodContract {
    mapping(address => uint256) public balances;

   
    function addBalance() public payable {
        balances[msg.sender] += msg.value;
    }

   
    function withdraw() public {
        // Must have >0 ETH deposited
        require(balances[msg.sender] > 0);

        
        (bool sent, ) = msg.sender.call{value: balances[msg.sender]}("");
        require(sent, "Failed to send ether");
   
        balances[msg.sender] = 0;
    }
}