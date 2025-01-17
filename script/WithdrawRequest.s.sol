// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {KlyraBridge} from "../src/Bridge.sol";
import {console} from "forge-std/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {strings} from "solidity-stringutils/strings.sol";

contract WithdrawRequestScript is Script {
    using strings for *;

    function run() external {
        uint256 withdrawerPrivateKey = vm.envUint("PRIVATE_KEY");
        address bridgeAddress = vm.envAddress("BRIDGE_ADDRESS");

        string memory withdrawRequestsStr = vm.envString("WITHDRAW_REQUESTS");
        require(bytes(withdrawRequestsStr).length > 0, "Provide withdraw requests");

        strings.slice memory s = withdrawRequestsStr.toSlice();
        strings.slice memory delim = ",".toSlice();
        uint256 count = s.count(delim) + 1;

        KlyraBridge.WithdrawalRequest[] memory withdrawRequests = new KlyraBridge.WithdrawalRequest[](count);

        for (uint256 i = 0; i < count; i++) {
            strings.slice memory request = s.split(delim);
            strings.slice memory colonDelim = ":".toSlice();

            require(request.count(colonDelim) == 1, "Invalid request format");

            string memory addrStr = request.split(colonDelim).toString();
            string memory amountStr = request.toString();

            address withdrawAddress = vm.parseAddress(addrStr);
            uint256 withdrawAmount = vm.parseUint(amountStr) * 1e18;

            require(withdrawAddress != address(0), "Invalid withdraw address");
            require(withdrawAmount > 0, "Invalid withdraw amount");

            withdrawRequests[i] = KlyraBridge.WithdrawalRequest({amount: withdrawAmount, to: withdrawAddress});
        }

        vm.startBroadcast(withdrawerPrivateKey);

        KlyraBridge bridge = KlyraBridge(bridgeAddress);
        bridge.requestWithdrawals(withdrawRequests);

        vm.stopBroadcast();
    }
}
