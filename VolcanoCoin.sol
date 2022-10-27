// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 @title Contract to implement functionality for management of VolcanoCoin
 @author Siva Puvvada
*/
contract VolcanoCoin is Ownable {
    uint totalSupply = 10000;
    uint supplyIncr = 1000;

    string symbol = "VOLCANO";
    struct Payment {
        uint amount;
        address recepient;
    }
    event Minted(uint);
    event Transfer(address indexed, uint);

    mapping(address => uint) public balances;
    mapping(address => Payment[]) userPayments;

    /**
     @notice Constructor to create VolcanoCoin
    */
    constructor() {
        balances[owner()] = totalSupply;
    }

    /**
    @notice This function allows owner of the contract to increase the coin supply in increments
            of 1000
    */
    function mint() public onlyOwner {
        totalSupply = totalSupply + supplyIncr;
        emit Minted(totalSupply);
    }

    /**
    @notice This function returns the total supply of this coin
    */
    function getTotalSupply() public view returns (uint) {
        return totalSupply;
    }

    /**
    @notice This function allows a user to transfer their balance to another user
    @param _to - Recepient's address
    @param _amount - Amount to transfer
    */
    function transfer(address payable _to, uint _amount)
        external
        returns (bool)
    {
        require(_amount > 0 && _amount <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender] - _amount;
        balances[_to] = balances[_to] + _amount;
        recordPayment(msg.sender, _to, _amount);
        emit Transfer(_to, _amount);
        return true;
    }

    /**
    @notice This function fetches the payments made by a user
    @param user - User(Sender) address
    */
    function fetchUserPayments(address user)
        external
        view
        returns (Payment[] memory)
    {
        return userPayments[user];
    }

    /**
    @notice This function records the payment made by the sender to a recepient
    @param _sender - Sender's address
    @param _receiver - Recepient's address
    @param _amount - Amount to transfer
    */
    function recordPayment(
        address _sender,
        address _receiver,
        uint _amount
    ) private {
        Payment memory payment = Payment({
            amount: _amount,
            recepient: _receiver
        });
        userPayments[_sender].push(payment);
    }

    /**
       @dev This function provides an ability for the owner to destroy and remove the contract from the blockchain
    */
    function kill() public onlyOwner {
        selfdestruct(payable(owner()));
    }
}
