// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {KlyraBridge} from "../src/Bridge.sol";

contract DeployBridge is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address sdaiAddress = vm.envAddress("SDAI_CONTRACT_ADDRESS");

        address[] memory allowedWithdrawers = new address[](1);

        vm.startBroadcast(deployerPrivateKey);

        KlyraBridge bridge = new KlyraBridge(sdaiAddress, allowedWithdrawers);

        vm.stopBroadcast();
    }
}