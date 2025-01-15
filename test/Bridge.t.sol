// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {KlyraBridge} from "../src/Bridge.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Test, console2} from "forge-std/Test.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MTK") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract BridgeTest is Test {
    KlyraBridge public bridge;
    MockERC20 public token;
    address public user;
    uint256 public constant INITIAL_BALANCE = 100 ether;

    event Bridge(
        uint256 indexed id,
        uint256 amount,
        address from,
        bytes toAddress
    );

    function setUp() public {
        token = new MockERC20();
        bridge = new KlyraBridge(address(token), new address[](0));
        user = makeAddr("user");

        // Mint tokens to user
        token.mint(user, INITIAL_BALANCE);

        // Approve bridge from user
        vm.prank(user);
        token.approve(address(bridge), type(uint256).max);
    }

    function test_Constructor() public {
        assertEq(address(bridge.sdai()), address(token));
        assertEq(bridge.currId(), 0);
        assertTrue(bridge.allowedWithdrawers(address(this)));

        // Check that additional allowed withdrawers are set correctly
        address[] memory additionalWithdrawers = new address[](2);
        additionalWithdrawers[0] = makeAddr("withdrawer0");
        additionalWithdrawers[1] = makeAddr("withdrawer1");

        KlyraBridge newBridge = new KlyraBridge(address(token), additionalWithdrawers);

        assertEq(address(newBridge.sdai()), address(token));
        assertEq(newBridge.currId(), 0);
        assertTrue(newBridge.allowedWithdrawers(address(this)));
        assertTrue(newBridge.allowedWithdrawers(additionalWithdrawers[0]));
        assertTrue(newBridge.allowedWithdrawers(additionalWithdrawers[1]));
    }

    function test_RevertIf_ZeroAddressInConstructor() public {
        vm.expectRevert("Invalid address");
        new KlyraBridge(address(0), new address[](0));
    }

    function test_Deposit() public {
        uint256 amount = 1 ether;
        bytes memory toAddress = abi.encode(address(0xdead));

        vm.prank(user);
        vm.expectEmit(true, true, true, true);
        emit Bridge(0, amount, user, toAddress);
        bridge.deposit(amount, toAddress);

        assertEq(token.balanceOf(address(bridge)), amount);
        assertEq(token.balanceOf(user), INITIAL_BALANCE - amount);
        assertEq(bridge.currId(), 1);
    }

    function test_RevertIf_ZeroAmount() public {
        bytes memory toAddress = abi.encode(address(0xdead));

        vm.prank(user);
        vm.expectRevert("Cannot bridge zero");
        bridge.deposit(0, toAddress);
    }

    function test_RevertIf_EmptyToAddress() public {
        vm.prank(user);
        vm.expectRevert("Invalid address");
        bridge.deposit(1 ether, "");
    }

    function test_RevertIf_InsufficientBalance() public {
        uint256 amount = INITIAL_BALANCE + 1;
        bytes memory toAddress = abi.encode(address(0xdead));

        vm.prank(user);
        vm.expectRevert();
        bridge.deposit(amount, toAddress);
    }

    function testFuzz_Deposit(uint256 amount, bytes calldata toAddress) public {
        vm.assume(amount > 0 && amount <= INITIAL_BALANCE);
        vm.assume(toAddress.length > 0);

        vm.prank(user);
        bridge.deposit(amount, toAddress);

        assertEq(token.balanceOf(address(bridge)), amount);
        assertEq(token.balanceOf(user), INITIAL_BALANCE - amount);
    }

    function test_SetAllowedWithdrawer() public {
        address withdrawer = makeAddr("withdrawer");
        assertFalse(bridge.allowedWithdrawers(withdrawer));

        bridge.setAllowedWithdrawer(withdrawer, true);
        assertTrue(bridge.allowedWithdrawers(withdrawer));

        bridge.setAllowedWithdrawer(withdrawer, false);
        assertFalse(bridge.allowedWithdrawers(withdrawer));

        bridge.setAllowedWithdrawer(withdrawer, false);
        assertFalse(bridge.allowedWithdrawers(withdrawer));

        bridge.setAllowedWithdrawer(withdrawer, true);
        assertTrue(bridge.allowedWithdrawers(withdrawer));

        bridge.setAllowedWithdrawer(withdrawer, true);
        assertTrue(bridge.allowedWithdrawers(withdrawer));
    }

    function test_RevertIf_NonOwnerSetsAllowedWithdrawer() public {
        address withdrawer = makeAddr("withdrawer");

        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user));
        bridge.setAllowedWithdrawer(withdrawer, true);
    }

    event WithdrawalRequested(
        uint256 indexed id,
        uint256 amount,
        address requester,
        address to
    );

    function test_RequestWithdrawal() public {
        address withdrawer = makeAddr("withdrawer");
        uint256 amount = 1000000;
        address to = makeAddr("recipient");

        bridge.setAllowedWithdrawer(withdrawer, true);

        vm.prank(withdrawer);
        vm.expectEmit(true, true, true, true);
        emit WithdrawalRequested(0, amount, withdrawer, to);
        bridge.requestWithdrawal(amount, to);

        (uint256 storedAmount, address requester, address storedTo) = bridge.withdrawalQueue(0);
        assertEq(storedAmount, amount);
        assertEq(requester, withdrawer);
        assertEq(storedTo, to);

        withdrawer = makeAddr("withdrawer2");
        amount = 2000000;
        to = makeAddr("recipient2");

        bridge.setAllowedWithdrawer(withdrawer, true);

        vm.prank(withdrawer);
        vm.expectEmit(true, true, true, true);
        emit WithdrawalRequested(1, amount, withdrawer, to);
        bridge.requestWithdrawal(amount, to);

        (storedAmount, requester, storedTo) = bridge.withdrawalQueue(1);
        assertEq(storedAmount, amount);
        assertEq(requester, withdrawer);
        assertEq(storedTo, to);
    }

    function test_RevertIf_NotAllowedToRequestWithdrawal() public {
        address withdrawer = makeAddr("withdrawer");
        uint256 amount = 1000000;
        address to = makeAddr("recipient");

        assertFalse(bridge.allowedWithdrawers(withdrawer));

        vm.prank(withdrawer);
        vm.expectRevert("Not allowed to withdraw");
        bridge.requestWithdrawal(amount, to);
    }

    function test_RevertIf_ZeroAmountRequestWithdrawal() public {
        address withdrawer = makeAddr("withdrawer");
        address to = makeAddr("recipient");
        bridge.setAllowedWithdrawer(withdrawer, true);

        vm.prank(withdrawer);
        vm.expectRevert("Cannot withdraw zero");
        bridge.requestWithdrawal(0, to);
    }

    function testFuzz_RequestWithdrawal(uint256 amount, address to) public {
        address withdrawer = makeAddr("withdrawer");

        bridge.setAllowedWithdrawer(withdrawer, true);

        vm.assume(amount > 0);
        vm.assume(to != address(0));

        vm.prank(withdrawer);
        bridge.requestWithdrawal(amount, to);

        (uint256 storedAmount, address requester, address storedTo) = bridge.withdrawalQueue(bridge.nextWithdrawalId() - 1);
        assertEq(storedAmount, amount);
        assertEq(requester, withdrawer);
        assertEq(storedTo, to);
    }

    event WithdrawalApproved(
        uint256 indexed id,
        uint256 amount,
        address requester,
        address to
    );

    function test_ApproveWithdrawal() public {
        address withdrawer = makeAddr("withdrawer");
        uint256 amount = 1000000;
        address to = makeAddr("recipient");

        token.mint(address(bridge), amount);

        bridge.setAllowedWithdrawer(withdrawer, true);
        vm.prank(withdrawer);
        bridge.requestWithdrawal(amount, to);

        vm.expectEmit(true, true, true, true);
        emit WithdrawalApproved(0, amount, withdrawer, to);
        bridge.approveWithdrawal(0);

        (uint256 storedAmount, address requester, address storedTo) = bridge.withdrawalQueue(0);
        assertEq(storedAmount, 0);
        assertEq(requester, address(0));
        assertEq(storedTo, address(0));

        assertEq(token.balanceOf(to), amount);
    }

    function test_RevertIf_InvalidWithdrawalID() public {
        vm.expectRevert("Invalid withdrawal ID");
        bridge.approveWithdrawal(0);
    }

    function testFuzz_ApproveWithdrawal(uint256 amount, address to) public {
        address withdrawer = makeAddr("withdrawer");
        bridge.setAllowedWithdrawer(withdrawer, true);

        vm.assume(to != address(0));
        vm.assume(amount > 0);
        vm.assume(amount < INITIAL_BALANCE);

        token.mint(address(bridge), amount);

        vm.prank(withdrawer);
        bridge.requestWithdrawal(amount, to);

        vm.expectEmit(true, true, true, true);
        emit WithdrawalApproved(0, amount, withdrawer, to);
        bridge.approveWithdrawal(0);

        (uint256 storedAmount, address requester, address storedTo) = bridge.withdrawalQueue(0);
        assertEq(storedAmount, 0);
        assertEq(requester, address(0));
        assertEq(storedTo, address(0));

        assertEq(token.balanceOf(to), amount);
    }
}
