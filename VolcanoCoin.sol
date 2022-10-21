// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 @title Contract to implement functionality for management of VolcanoCoin
 @author Siva Puvvada
*/
contract VolcanoCoin{

    uint totalSupply = 10000;
    address owner;

    struct Payment{
        uint amount;
        address recepient;
    }
    event NewSupply(uint);
    event CoinTransfer(address, uint);

    mapping (address => uint) public balances;
    mapping (address => Payment[]) userPayments;

    /**
     @dev Modifier to check if the sender is the owner of the contract
    */
    modifier onlyOwner(){
        if(msg.sender == owner){
            _;
        }
    }

    /**
     @notice Constructor to create VolcanoCoin
    */
    constructor(){
        owner = msg.sender;
        balances[owner] = totalSupply;
    }
    /**
    @notice This function allows owner of the contract to increase the coin supply in increments
            of 1000
    */
    function addSupply() public onlyOwner{
        totalSupply = totalSupply +1000;
        emit NewSupply(totalSupply);
    }
    /**
    @notice This function returns the total supply of this coin
    */
    function getTotalSupply() public view returns(uint){
        return totalSupply;
    }
    /**
    @notice This function allows a user to transfer their balance to another user
    @param to - Recepient's address
    @param amount - Amount to transfer
    */
    function transfer(address to, uint amount) payable external{
        require(balances[msg.sender]>0);
        balances[msg.sender] = balances[msg.sender] - amount;
        balances[to] = balances[to] + amount;
        Payment memory payment = Payment({amount:amount,recepient:to});
        userPayments[owner].push(payment);
        emit CoinTransfer(to,amount);        
    }
}
