//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LendingBorrowing {
    struct User {
        uint256 collateral;
        uint256 debt;
    }

    IERC20 public collateralToken;
    IERC20 public borrowToken;

    mapping(address => User) public users;
    uint256 public constant LTV = 75; //Loan-to-value ratio
    uint256 public constant INTEREST_RATE = 10; // 10% interest per period
    uint256 public constant LIQUIDATION_THRESHOLD = 80; //If collateral value drops below 80%

    constructor(address _collateralToken, address _borrowToken) {
        collateralToken = IERC20(_collateralToken);
        borrowToken = IERC0(_borrowToken);
    }

    function deposit(uint256 _amount) external {
        require(_amount > 0, "Amount cant be less that or equal to zero");

        collateralToken.transferFrom(msg.sender, address(this), _amount);
        user[msg.sender].collateral += _amount;
    }

    function borrow(uint256 _amount) external {
        User storage user = users[msg.sender];

        uint256 maxBorrow = (user.collateral * LTV) / 100;
        require(_amount > 0 && _amount <= maxBorrow, "Exceeds borrow limit");

        user.debt += _amount;
        borrowToken.transfer(msg.sender, _amount);
    }
}
