// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {KlyraBridge} from "../src/Bridge.sol";
import {console} from "forge-std/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DepositScript is Script {
    function run() external {
        uint256 depositorPrivateKey = vm.envUint("PRIVATE_KEY");
        address bridgeAddress = vm.envAddress("BRIDGE_ADDRESS");
        address sdaiAddress = vm.envAddress("SDAI_CONTRACT_ADDRESS");

        uint256 depositAmount = vm.envUint("DEPOSIT_AMOUNT") * 1e18;
        require(depositAmount > 0, "Provide deposit amount as argument");

        bytes memory toAddress = vm.envBytes("TO_ADDRESS");
        require(toAddress.length > 0, "Provide Klyra chain destination address as argument");

        vm.startBroadcast(depositorPrivateKey);

        IERC20 sdai = IERC20(sdaiAddress);
        sdai.approve(bridgeAddress, depositAmount);

        KlyraBridge bridge = KlyraBridge(bridgeAddress);
        bridge.deposit(depositAmount, toAddress);

        vm.stopBroadcast();
    }
}