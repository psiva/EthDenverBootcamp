// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

contract GasContract {
    uint256 public totalSupply = 0; // cannot be updated
    uint256 private paymentCounter = 0;

    mapping(address => uint256) private balances;
    mapping(address => Payment[]) private payments;
    mapping(address => uint256) public whitelist;

    address[5] public administrators;

    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend,
        GroupPayment
    }

    struct Payment {
        uint256 paymentID;
        uint256 amount;
        PaymentType paymentType;
        address recipient;
    }
    struct ImportantStruct {
        uint256 valueA; // max 3 digits
        uint256 bigValue;
        uint256 valueB; // max 3 digits
    }

    modifier checkIfWhiteListed(address sender) {
        require(msg.sender == sender, "originator not the sender");
        uint256 usersTier = whitelist[msg.sender];

        _;
    }

    event supplyChanged(address indexed, uint256 indexed);
    event Transfer(address indexed recipient, uint256 amount);
    event WhiteListTransfer(address indexed);
    event AddedToWhitelist(address indexed userAddress, uint256 tier);

    constructor(address[5] memory _admins, uint256 _totalSupply) {
        totalSupply = _totalSupply;
        administrators = _admins;
        balances[msg.sender] = totalSupply;
    }

    function checkForAdmin(address _user) private view returns (bool admin_) {
        for (uint8 ii = 0; ii < administrators.length; ii++) {
            if (administrators[ii] == _user) {
                return true;
            }
        }
        revert("Not admin");
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string memory _name
    ) external {
        require(
            balances[msg.sender] >= _amount,
            "Sender has insufficient balance"
        );
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        emit Transfer(_recipient, _amount);
        payments[msg.sender].push(
            Payment(
                ++paymentCounter,
                _amount,
                PaymentType.BasicPayment,
                _recipient
            )
        );
    }

    function updatePayment(
        address _user,
        uint256 _ID,
        uint256 _amount,
        PaymentType _type
    ) external {
        checkForAdmin(msg.sender);
        Payment[] storage userPayments = payments[_user];
        uint256 len = userPayments.length;
        for (uint256 ii = 0; ii < len; ii++) {
            if (userPayments[ii].paymentID == _ID) {
                userPayments[ii] = Payment(_ID, _amount, _type, _user);
                break;
            }
        }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) external {
        checkForAdmin(msg.sender);
        whitelist[_userAddrs] = _tier < 3 ? _tier : 3;
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount,
        ImportantStruct memory _struct
    ) external checkIfWhiteListed(msg.sender) {
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        balances[msg.sender] += whitelist[msg.sender];
        balances[_recipient] -= whitelist[msg.sender];
        emit WhiteListTransfer(_recipient);
    }

    function balanceOf(address _user) external view returns (uint256 balance_) {
        return balances[_user];
    }

    function getTradingMode() public pure returns (bool mode_) {
        return true;
    }

    function getPayments(address _user)
        public
        view
        returns (Payment[] memory payments_)
    {
        require(_user != address(0), "non zero address expected");
        return payments[_user];
    }
}
