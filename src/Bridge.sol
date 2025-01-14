pragma solidity ^0.8.0;
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
contract Bridge is ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public owner;
    uint256 public currId;
    IERC20 public sdai;

    event Bridge(
        uint256 indexed id,
        uint256 amount,
        address from,
        bytes toAddress
    );

    constructor(address _sdai) {
        require(_sdai != address(0), "Invalid address");
        sdai = IERC20(_sdai);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function deposit(
        uint256 amount,
        bytes calldata toAddress
    ) public nonReentrant {
        require(amount > 0, "Cannot bridge zero");
        require(toAddress.length != 0, "Invalid address");

        sdai.safeTransferFrom(msg.sender, address(this), amount);

        emit Bridge(currId++, amount, msg.sender, toAddress);
    }
}
