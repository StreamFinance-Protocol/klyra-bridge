# Klyra Bridge

## Deployment

### Environment Variables

#### sDAI mainnet address
0x83f20f44975d03b1b09e64809b757c47f942beea

#### sUSDS Base address
0x5875eEE11Cf8398102FdAd704C9E96607675467a

#### sUSDS mainnet address
0xa3931d71877C0E7a3148CB7Eb4463524FEc27fbD

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
