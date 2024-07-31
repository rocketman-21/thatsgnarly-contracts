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

interface IMintHouseEvents {
    event MintCreated(uint256 indexed tokenId, uint256 startTime, uint256 endTime);

    event MintSettled(
        uint256 indexed tokenId,
        address winner,
        uint256 amount,
        uint256 pointsPaidToCreators,
        uint256 ethPaidToCreators
    );

    event PriceUpdated(uint256 price);

    event DurationUpdated(uint256 duration);

    event IntervalUpdated(uint256 interval);

    event CreatorRateBpsUpdated(uint256 rateBps);
}

interface IMintHouse is IMintHouseEvents {
    ///                                                          ///
    ///                           ERRORS                         ///
    ///                                                          ///

    /// @dev Reverts if the function caller is not the manager.
    error NOT_MANAGER();

    /// @dev Reverts if address 0 is passed but not allowed
    error ADDRESS_ZERO();

    /// @dev Reverts if the supplied token ID for a bid does not match the mint's token ID.
    error INVALID_TOKEN_ID();

    /// @dev Reverts if the mint has already expired.
    error DROP_EXPIRED();

    /// @dev Reverts if bps is greater than 10,000.
    error INVALID_BPS();

    /// @dev Reverts if the creator rate is below the minimum required creator rate basis points.
    error CREATOR_RATE_TOO_LOW();

    /// @dev Reverts if the new minimum creator rate is not greater than the previous minimum creator rate.
    error MIN_CREATOR_RATE_NOT_INCREASED();

    /// @dev Reverts if the minimum creator rate is not less than or equal to the creator rate.
    error MIN_CREATOR_RATE_ABOVE_CREATOR_RATE();

    /// @dev Reverts if the mint start time is not set, indicating the mint hasn't begun.
    error DROP_NOT_BEGUN();

    /// @dev Reverts if the mint has already been settled.
    error DROP_ALREADY_SETTLED();

    /// @dev Reverts if the mint has not yet completed based on the current block timestamp.
    error DROP_NOT_COMPLETED();

    /// @dev Reverts if an existing mint is in progress.
    error DROP_ALREADY_IN_PROGRESS();

    /// @dev Reverts if the duration is < 60 seconds.
    error DURATION_TOO_LOW();

    struct Mint {
        // ERC1155 token ID
        uint256 tokenId;
        // The current highest bid amount
        uint256 amount;
        // The time that the mint started
        uint256 startTime;
        // The time that the mint is scheduled to end
        uint256 endTime;
        // The address of the current highest bid
        address payable bidder;
        // The address of the referral account who referred the current highest bidder
        address payable referral;
        // Whether or not the mint has been settled
        bool settled;
    }

    struct PaymentShares {
        // Scaled means it hasn't been divided by 10,000 for BPS to allow for precision in division by
        // consuming functions
        uint256 creatorDirectScaled;
        uint256 creatorGovernance;
        uint256 owner;
    }

    struct PaidToCreators {
        uint256 points;
        uint256 eth;
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

    /**
     * @notice Initialize the mint house and base contracts.
     * @param initialOwner The address of the owner.
     * @param mintParams The mint params for mints.
     */
    function initialize(address initialOwner, MintParams calldata mintParams) external;
}
