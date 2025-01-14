// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {KlyraBridge} from "../src/Bridge.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

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
        bridge = new KlyraBridge(address(token));
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
    }

    function test_RevertIf_ZeroAddressInConstructor() public {
        vm.expectRevert("Invalid address");
        new KlyraBridge(address(0));
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
}
