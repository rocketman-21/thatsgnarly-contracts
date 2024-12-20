# thatsgnarly contracts

## Overview

This repository contains the smart contracts for the `thatsgnar.ly` project. The contracts are written in Solidity and are designed to manage the minting and sale of NFTs (Non-Fungible Tokens) on a Zora 1155 contract with specific features such as setting prices, durations, intervals, and handling royalties. They enable the permissionless curation of art pieces to build a community owned collection of media

## Contracts

### MintHouse.sol

The `MintHouse` contract is the primary contract in this repository. It includes the following key functionalities:

- **Set Price**: Allows the owner to set the mint price.
- **Set Duration**: Allows the owner to set the duration of the mint.
- **Set Interval**: Allows the owner to set the interval between mints.
- **Create Mint**: Function to allow anyone create a mint, handle potential failures, and update royalties and permissions.

#### Functions

- `setPrice(uint96 _price)`: Sets the mint price. Only callable by the owner.
- `setDuration(uint64 _duration)`: Sets the duration of the mint. Only callable by the owner.
- `setInterval(uint256 _interval)`: Sets the interval between mints. Only callable by the owner.
- `_createMint()`: Internal function to create a mint, handle potential failures, and update royalties and permissions.

## Events

- `PriceUpdated(uint96 _price)`: Emitted when the mint price is updated.
- `DurationUpdated(uint64 _duration)`: Emitted when the mint duration is updated.
- `IntervalUpdated(uint256 _interval)`: Emitted when the mint interval is updated.
- `CultureIndexUpdated(ICultureIndex _cultureIndex)`: Emitted when the CultureIndex is updated.
- `MintCreated(uint256 tokenId, uint64 startTime, uint64 endTime, uint256 price)`: Emitted when a new mint is created.

### CultureIndex.sol

The `CultureIndex` contract manages the voting and dropping of art pieces. It includes functionalities for casting votes, creating art pieces, and managing the top-voted pieces. Pieces are voted on by Gnars DAO holders. The top piece can be dropped by the `MintHouse` contract.

#### Functions

- `getAccountVotingPowerForPiece(uint256 pieceId, address account)`: Returns the voting power of an account for a specific piece.
- `vote(uint256 pieceId)`: Casts a vote for a specific art piece.
- `voteForMany(uint256[] calldata pieceIds)`: Casts votes for multiple art pieces.
- `createPiece(ArtPieceMetadata calldata metadata, CreatorBps[] calldata creatorArray)`: Creates a new piece of art with associated metadata and creators.

## Events

- `VoteCast(uint256 pieceId, address voter, uint256 weight, uint256 totalWeight)`: Emitted when a vote is cast.
- `PieceCreated(uint256 pieceId, address sponsor, ArtPieceMetadata metadata, CreatorBps[] creatorArray)`: Emitted when a new piece is created.
- `PieceDropped(uint256 pieceId, address dropper)`: Emitted when a piece is dropped.

### Deploy.s.sol

The `DeployContracts` script is used to deploy the contracts to the blockchain. It handles the deployment of the `CultureIndex`, `MaxHeap`, and `MintHouse` contracts, as well as their proxies. It also initializes the proxies with the necessary parameters.

#### Functions

- `run()`: Main function to deploy and initialize the contracts.
- `deployCultureIndexProxy()`: Deploys the proxy for the `CultureIndex` contract.
- `deployMaxHeapProxy()`: Deploys the proxy for the `MaxHeap` contract.
- `deployMintHouseProxy()`: Deploys the proxy for the `MintHouse` contract.
- `initializeProxies()`: Initializes the deployed proxies with the necessary parameters.
- `writeDeploymentDetailsToFile(uint256 chainID)`: Writes the deployment details to a file for record-keeping.
