// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {KlyraBridge} from "../src/Bridge.sol";
import {strings} from "solidity-stringutils/strings.sol";

contract ApproveWithdrawalScript is Script {
    function run() external {
        uint256 withdrawerPrivateKey = vm.envUint("PRIVATE_KEY");
        address bridgeAddress = vm.envAddress("BRIDGE_ADDRESS");

        string memory approveIdsStr = vm.envString("APPROVE_IDS");
        require(bytes(approveIdsStr).length > 0, "Provide approve ids");

        strings.slice memory s = strings.toSlice(approveIdsStr);
        strings.slice memory delim = strings.toSlice(",");
        uint256 count = strings.count(s, delim) + 1;

        uint256[] memory approveIds = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            string memory idStr = strings.toString(strings.split(s, delim));
            approveIds[i] = vm.parseUint(idStr);
        }

        vm.startBroadcast(withdrawerPrivateKey);

        KlyraBridge bridge = KlyraBridge(bridgeAddress);
        bridge.approveWithdrawals(approveIds);

        vm.stopBroadcast();
    }
}