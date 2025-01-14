pragma solidity ^0.8.0;
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract KlyraBridge is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    uint256 public currId;
    IERC20 public sdai;
    mapping(uint256 => WithdrawalRequest) public withdrawalQueue;
    mapping(address => bool) public allowedWithdrawers;
    uint256 public nextWithdrawalId;

    struct WithdrawalRequest {
        uint256 amount;
        address requester;
        address to;
    }

    event Bridge(
        uint256 indexed id,
        uint256 amount,
        address from,
        bytes toAddress
    );

    event WithdrawalRequested(
        uint256 indexed id,
        uint256 amount,
        address requester,
        address to
    );

    event WithdrawalApproved(
        uint256 indexed id,
        uint256 amount,
        address requester,
        address to
    );

    constructor(address _sdai) Ownable(msg.sender) {
        require(_sdai != address(0), "Invalid address");
        sdai = IERC20(_sdai);
        allowedWithdrawers[msg.sender] = true;
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

    function setAllowedWithdrawer(
        address withdrawer,
        bool allowed
    ) public onlyOwner {
        allowedWithdrawers[withdrawer] = allowed;
    }

    function withdraw(uint256 amount, address to) public nonReentrant {
        require(allowedWithdrawers[msg.sender], "Not allowed to withdraw");
        require(amount > 0, "Cannot withdraw zero");
        
        withdrawalQueue[nextWithdrawalId] = WithdrawalRequest({
            amount: amount,
            requester: msg.sender,
            to: to
        });

        emit WithdrawalRequested(nextWithdrawalId, amount, msg.sender, to);
        nextWithdrawalId++;
    }

    function approveWithdrawal(uint256 id) public onlyOwner {
        require(withdrawalQueue[id].amount > 0, "Invalid withdrawal ID");
        WithdrawalRequest storage request = withdrawalQueue[id];

        sdai.safeTransfer(request.to, request.amount);

        delete withdrawalQueue[id];

        emit WithdrawalApproved(id, request.amount, request.requester, request.to);
    }
}
