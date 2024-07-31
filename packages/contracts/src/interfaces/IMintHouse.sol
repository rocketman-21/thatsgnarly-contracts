// SPDX-License-Identifier: GPL-3.0

/// @title Interface for Gnars Mint Houses

/*********************************
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░██░░░████░░██░░░████░░░ *
 * ░░██████░░░████████░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 *********************************/

pragma solidity ^0.8.22;

import { ICultureIndex } from "./ICultureIndex.sol";

interface IMintHouseEvents {
    event MintCreated(
        uint256 indexed tokenId,
        uint256 startTime,
        uint256 endTime,
        uint256 price,
        uint256 creatorRateBps
    );

    event PriceUpdated(uint256 price);

    event DurationUpdated(uint256 duration);

    event IntervalUpdated(uint256 interval);

    event CreatorRateBpsUpdated(uint256 rateBps);

    event CultureIndexUpdated(ICultureIndex cultureIndex);
}

interface IMintHouse is IMintHouseEvents {
    ///                                                          ///
    ///                           ERRORS                         ///
    ///                                                          ///

    /// @dev Reverts if address 0 is passed but not allowed
    error ADDRESS_ZERO();

    /// @dev Reverts if bps is greater than 10,000.
    error INVALID_BPS();

    /// @dev Reverts if the creator rate is below the minimum required creator rate basis points.
    error CREATOR_RATE_TOO_LOW();

    /// @dev Reverts if the mint has not yet completed based on the current block timestamp.
    error DROP_NOT_COMPLETED();

    /// @dev Reverts if the duration is < 60 seconds.
    error DURATION_TOO_LOW();

    struct Mint {
        // ERC1155 token ID
        uint256 tokenId;
        // The current highest bid amount
        uint256 price;
        // The time that the mint started
        uint256 startTime;
        // The time that the mint is scheduled to end
        uint256 endTime;
        // The creator rate basis points of each mint - the share of the winning bid that is reserved for the creator
        uint256 creatorRateBps;
    }

    /**
     * @notice The mint parameters
     * @param price The price of each mint
     * @param duration The duration of each mint
     * @param interval The minimum time between each mint
     * @param creatorRateBps The creator rate basis points of each mint - the share of the winning bid that is reserved for the creator
     */
    struct MintParams {
        uint256 price;
        uint256 duration;
        uint256 interval;
        uint256 creatorRateBps;
    }

    function createNewMint() external;

    function pause() external;

    function unpause() external;

    function setPrice(uint256 price) external;

    function setDuration(uint256 duration) external;

    function setInterval(uint256 interval) external;

    function setCreatorRateBps(uint256 _creatorRateBps) external;

    function setCultureIndex(ICultureIndex _cultureIndex) external;

    /**
     * @notice Initialize the mint house and base contracts.
     * @param initialOwner The address of the owner.
     * @param cultureIndex The address of the culture index.
     * @param mintParams The mint params for mints.
     */
    function initialize(address initialOwner, address cultureIndex, MintParams calldata mintParams) external;
}
