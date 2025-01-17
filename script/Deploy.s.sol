// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {KlyraBridge} from "../src/Bridge.sol";
import {console} from "forge-std/console.sol";
import {strings} from "solidity-stringutils/strings.sol";

contract DeployBridge is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address sdaiAddress = vm.envAddress("SDAI_CONTRACT_ADDRESS");

        string memory withdrawersStr = vm.envString("ALLOWED_WITHDRAWERS");

        strings.slice memory s = strings.toSlice(withdrawersStr);
        strings.slice memory delim = strings.toSlice(",");
        uint256 count = strings.count(s, delim) + 1;

        address[] memory allowedWithdrawers = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            string memory addrStr = strings.toString(strings.split(s, delim));
            allowedWithdrawers[i] = vm.parseAddress(addrStr);
        }

        vm.startBroadcast(deployerPrivateKey);

        new KlyraBridge(sdaiAddress, allowedWithdrawers);

        vm.stopBroadcast();
    }
}
