// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {KlyraBridge} from "../src/Bridge.sol";

contract QueryWithdrawalsScript is Script {
    KlyraBridge private bridge;

    function setUp() public {
        address bridgeAddress = vm.envAddress("BRIDGE_ADDRESS");
        bridge = KlyraBridge(bridgeAddress);
    }

    function queryNextWithdrawalId() external view {
        uint256 nextId = bridge.nextWithdrawalId();
        console.log("Next withdrawal ID:", nextId);
    }

    function queryUnapprovedWithdrawals() external view {
        uint256 nextId = bridge.nextWithdrawalId();
        console.log("Checking for unapproved withdrawals...");

        bool foundAny = false;
        for (uint256 i = 0; i < nextId; i++) {
            (uint256 amount, address to) = bridge.withdrawalQueue(i);
            if (amount > 0) {
                if (!foundAny) {
                    foundAny = true;
                }
                console.log("Found unapproved withdrawal:");
                console.log("  ID:", i);
                console.log("  Amount:", amount);
                console.log("  To:", to);
                console.log("-------------------");
            }
        }

        if (!foundAny) {
            console.log("No unapproved withdrawals found");
        }
    }
}
