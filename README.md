# Klyra Bridge

## Deployment

### Environment Variables

#### sDAI mainnet address
SDAI_CONTRACT_ADDRESS=0x83f20f44975d03b1b09e64809b757c47f942beea

#### sUSDS Base address
SDAI_CONTRACT_ADDRESS=0x5875eEE11Cf8398102FdAd704C9E96607675467a

#### sUSDS mainnet address
SDAI_CONTRACT_ADDRESS=0xa3931d71877C0E7a3148CB7Eb4463524FEc27fbD

#### Allowed withdrawer addresses
ALLOWED_WITHDRAWERS=address1,address2,address3

### Shell Commands

To deploy on Eth Mainnet, run the following command:
```shell
forge script script/Deploy.s.sol:DeployBridge \
    --rpc-url $ETH_RPC_URL \
    --broadcast \
    --verify \
    --etherscan-api-key $ETHERSCAN_API_KEY
```

To deploy to Base Mainnet, run the following command:
```shell
forge script script/Deploy.s.sol:DeployBridge \
    --rpc-url $BASE_RPC_URL \
    --broadcast \
    --verify \
    --verifier etherscan \
    --etherscan-api-key $BASESCAN_API_KEY \
    --verifier-url https://api.basescan.org/api
```

## Depositing
In order to deposit, set the following environment variables:

-   SDAI_CONTRACT_ADDRESS (should correspond to the address that is used by the contract)
-   DEPOSIT_AMOUNT (amount of sDAI to deposit, 1 indicates 1 sDAI)
-   TO_ADDRESS (Klyra chain destination address)
-   ETH_RPC_URL/BASE_RPC_URL (RPC URL of the chain where the deposit is made)
-   PRIVATE_KEY (private key of the depositor)
-   BRIDGE_ADDRESS (address of the bridge)

Then, run the following command:
For Eth Mainnet:
```
forge script script/Deposit.s.sol:DepositScript --rpc-url $ETH_RPC_URL --broadcast
```

For Base Mainnet:
```
forge script script/Deposit.s.sol:DepositScript --rpc-url $BASE_RPC_URL --broadcast
```

## Requesting Withdrawals
In order to request withdrawals, set the following environment variables:

-   PRIVATE_KEY (private key of the withdrawer)
-   BRIDGE_ADDRESS (address of the bridge)
-   WITHDRAW_REQUESTS (comma separated list of withdraw requests, each request is in the format of "address:amount", example: 0xf8D7136205e42D34b5ee918bDAABef21327b9B66:1,0x70e1b787A5D677a5906AccCF0B4F387b8Bb1B5C3:2)

Then, run the following command:
For Eth Mainnet:
```
forge script script/WithdrawRequest.s.sol:WithdrawRequestScript --rpc-url $ETH_RPC_URL --broadcast
```

For Base Mainnet:
```
forge script script/WithdrawRequest.s.sol:WithdrawRequestScript --rpc-url $BASE_RPC_URL --broadcast
```

## Approving Withdrawals
In order to approve withdrawals, set the following environment variables:

-   PRIVATE_KEY (private key of the withdrawer)
-   BRIDGE_ADDRESS (address of the bridge)
-   APPROVE_IDS (comma separated list of withdraw request ids, example: 1,2)

Then, run the following command:
For Eth Mainnet:
```
forge script script/ApproveWithdrawal.s.sol:ApproveWithdrawalScript --rpc-url $ETH_RPC_URL --broadcast
```

For Base Mainnet:
```
forge script script/ApproveWithdrawal.s.sol:ApproveWithdrawalScript --rpc-url $BASE_RPC_URL --broadcast
```

## Querying Withdrawals
### Querying Next Withdrawal ID
For Eth Mainnet:
```
forge script script/QueryWithdrawals.s.sol:QueryWithdrawalsScript --sig "queryNextWithdrawalId()" --rpc-url $ETH_RPC_URL -vvv
```

For Base Mainnet:
```
forge script script/QueryWithdrawals.s.sol:QueryWithdrawalsScript --sig "queryNextWithdrawalId()" --rpc-url $BASE_RPC_URL -vvv
```
### Querying Unapproved Withdrawals
For Eth Mainnet:
```
forge script script/QueryWithdrawals.s.sol:QueryWithdrawalsScript --sig "queryUnapprovedWithdrawals()" --rpc-url $ETH_RPC_URL -vvv
```

For Base Mainnet:
```
forge script script/QueryWithdrawals.s.sol:QueryWithdrawalsScript --sig "queryUnapprovedWithdrawals()" --rpc-url $BASE_RPC_URL -vvv
```


## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
