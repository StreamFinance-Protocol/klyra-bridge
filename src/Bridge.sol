pragma solidity ^0.8.0;
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
<<<<<<< HEAD
contract Bridge is ReentrancyGuard {
=======
contract KlyraBridge is ReentrancyGuard {
>>>>>>> a34ce28 ([BRIDGE-2] Testing: init deposit tests)
    using SafeERC20 for IERC20;

    address public owner;
    uint256 public currId;
    IERC20 public sdai;
    WithdrawalRequest[] public withdrawalQueue;
    uint256 public nextWithdrawalId;

    struct WithdrawalRequest {
        uint256 id;
        uint256 amount;
        address requester;
        bool approved;
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
        address requester
    );

    event WithdrawalApproved(
        uint256 indexed id,
        uint256 amount,
        address requester
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

    function withdraw(uint256 amount) public nonReentrant {
        require(amount > 0, "Cannot withdraw zero");

        withdrawalQueue.push(WithdrawalRequest({
            id: nextWithdrawalId,
            amount: amount,
            requester: msg.sender,
            approved: false
        }));

        emit WithdrawalRequested(nextWithdrawalId, amount, msg.sender);
        nextWithdrawalId++;
    }

    function approveWithdrawal(uint256 id) public onlyOwner {
        require(id < withdrawalQueue.length, "Invalid withdrawal ID");
        WithdrawalRequest storage request = withdrawalQueue[id];
        require(!request.approved, "Already approved");

        request.approved = true;
        sdai.safeTransfer(request.requester, request.amount);

        emit WithdrawalApproved(id, request.amount, request.requester);
    }
}
