//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LandB {
    IERC20 public collateralToken;
    IERC20 public borrowToken;

    struct User {
        uint256 collateral;
        uint256 debt;
    }

    mapping(address => User) public users;
    uint256 public constant LTV = 75; //Loan-to-value ratio
    uint256 public constant INTEREST_RATE = 10; // 10% interest per period
    uint256 public constant LIQUIDATION_THRESHOLD = 80; //If collateral value drops below 80%
    constructor(address _collateral, address _borrowed) {
        collateralToken = IERC20(_collateral);
        borrowToken = IERC20(_borrowed);
    }

    function deposit(uint256 _amount) external {
        require(_amount > 0, "not permissible");
        collateralToken.transferFrom(msg.sender, address(this), _amount);
        Users[msg.sender].collateral += _amount;
    }

    function borrow(uint256 _amount) external {
        User storage user = users[msg.sender];
        uint256 maxBorrow = (user.collateral * LTV) / 100;
        require(_amount > 0 && _amount <= maxBorrow, "not permissible");

        borrowToken.transfer(msg.sender, _amount);
        user.debt += _amount;
    }

    function repay(uint256 _amount) external {
        User storage user = users[msg.sender];
        require(user.debt > 0, "not applicable");

        uint256 interest = (user.debt * INTEREST_RATE) / 100;
        uint256 totalAmount = user.debt + interest;
        require(totalAmount <= _amount, "send more");

        borrowToken.transferFrom(msg.sender, address(this), _amount);
        user.debt = 0;
    }
    function liquidate(address _borrower) external {
        User storage user = users[_borrower];

        uint256 maxDebtAllowed = (user.collateral * LIQUIDATION_THRESHOLD) /
            100;
        require(user.debt > maxDebtAllowed, "User is not liquidatable");

        uint256 seizedCollateral = user.collateral / 2; // Liquidator gets 50% of collateral
        user.collateral -= seizedCollateral;
        user.debt = 0;

        collateralToken.transfer(msg.sender, seizedCollateral);
    }
    function getUserData(
        address _user
    ) external view returns (uint256 collateral, uint256 debt) {
        User storage user = users[_user];
        return (user.collateral, user.debt);
    }
}
