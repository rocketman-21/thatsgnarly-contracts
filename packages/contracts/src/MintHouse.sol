// SPDX-License-Identifier: GPL-3.0

/// @title A Mint House

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

// LICENSE
// MintHouse.sol is a modified version of Zora's AuctionHouse.sol:
// https://github.com/ourzora/auction-house/blob/54a12ec1a6cf562e49f0a4917990474b11350a2d/contracts/AuctionHouse.sol
//
// MintHouse.sol source code Copyright Zora licensed under the GPL-3.0 license.

pragma solidity ^0.8.22;

import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import { IMintHouse } from "./interfaces/IMintHouse.sol";
import { ICultureIndex } from "./interfaces/ICultureIndex.sol";

import { UUPS } from "./proxy/UUPS.sol";

//TODO use 1e6 for bps - to mimic splits

contract MintHouse is IMintHouse, UUPS, PausableUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    // The minimum price accepted in a mint
    uint256 public price;

    // The split of the mint proceeds that is reserved for the creator of the Art Piece in basis points
    uint256 public creatorRateBps;

    // The duration of a single mint in seconds
    uint256 public duration;

    // The minimum time between each mint
    uint256 public interval;

    // The active mint
    IMintHouse.Mint public mint;

    ICultureIndex public cultureIndex;

    ///                                                          ///
    ///                         CONSTRUCTOR                      ///
    ///                                                          ///

    constructor() payable initializer {}

    ///                                                          ///
    ///                         INITIALIZER                      ///
    ///                                                          ///

    /**
     * @notice Initialize the mint house and base contracts,
     * populate configuration values, and pause the contract.
     * @dev This function can only be called once.
     * @param _initialOwner The address of the owner.
     * @param _cultureIndex The address of the culture index.
     * @param _mintParams The mint params for mints.
     */
    function initialize(
        address _initialOwner,
        address _cultureIndex,
        MintParams calldata _mintParams
    ) external initializer {
        if (_cultureIndex == address(0)) revert ADDRESS_ZERO();
        if (_initialOwner == address(0)) revert ADDRESS_ZERO();

        __Pausable_init();
        __ReentrancyGuard_init();
        __Ownable_init(_initialOwner);

        _pause();

        // set mint params
        price = _mintParams.price;
        duration = _mintParams.duration;
        interval = _mintParams.interval;
        creatorRateBps = _mintParams.creatorRateBps;

        // set contracts
        cultureIndex = ICultureIndex(_cultureIndex);
    }

    /**
     * @notice Create a new mint.
     */
    function createNewMint() external override nonReentrant whenNotPaused {
        // TODO add checks here

        _createMint();
    }

    /**
     * @notice Pause the Mint house.
     * @dev This function can only be called by the owner when the
     * contract is unpaused. While no new mints can be started when paused,
     * anyone can settle an ongoing mint.
     */
    function pause() external override onlyOwner {
        _pause();
    }

    /**
     * @notice Set the split of the winning bid that is reserved for the creator of the Art Piece (token) in basis points.
     * @dev Only callable by the owner.
     * @param _creatorRateBps New creator rate in basis points.
     */
    function setCreatorRateBps(uint256 _creatorRateBps) external onlyOwner {
        if (_creatorRateBps > 10_000) revert INVALID_BPS();
        creatorRateBps = _creatorRateBps;

        emit CreatorRateBpsUpdated(_creatorRateBps);
    }

    /**
     * @notice Unpause the Mint house.
     * @dev This function can only be called by the owner when the
     * contract is paused. If required, this function will start a new mint.
     */
    function unpause() external override onlyOwner {
        _unpause();

        // TODO
        // if (mint.startTime == 0) {
        //     _createMint();
        // }
    }

    /**
     * @notice Set the mint price.
     * @dev Only callable by the owner.
     */
    function setPrice(uint256 _price) external override onlyOwner {
        price = _price;

        emit PriceUpdated(_price);
    }

    /**
     * @notice Set the duration of the mint.
     * @dev Only callable by the owner.
     * @param _duration New duration for the mint.
     */
    function setDuration(uint256 _duration) external onlyOwner {
        if (_duration < 60) revert DURATION_TOO_LOW();

        duration = _duration;

        emit DurationUpdated(_duration);
    }

    /**
     * @notice Set the interval between mints.
     * @dev Only callable by the owner.
     * @param _interval New interval between mints.
     */
    function setInterval(uint256 _interval) external override onlyOwner {
        interval = _interval;

        emit IntervalUpdated(_interval);
    }

    /**
     * @notice Set the token CultureIndex.
     * @dev Only callable by the owner
     */
    function setCultureIndex(ICultureIndex _cultureIndex) external onlyOwner nonReentrant {
        cultureIndex = _cultureIndex;

        emit CultureIndexUpdated(_cultureIndex);
    }

    /**
     * @notice Create a mint.
     * @dev Store the mint details in the `mint` state variable and emit an MintCreated event.
     * If the mint reverts, the minter was updated without pausing this contract first. To remedy this,
     * catch the revert and pause this contract.
     */
    function _createMint() internal {
        // TODO fill in
        // try revolutionToken.mint() returns (uint256 tokenId) {
        //     uint256 startTime = block.timestamp;
        //     uint256 endTime = startTime + duration;
        //     mint = Mint({
        //         tokenId: tokenId,
        //         amount: 0,
        //         startTime: startTime,
        //         endTime: endTime,
        //         bidder: payable(0),
        //         settled: false,
        //         referral: payable(0)
        //     });
        //     emit MintCreated(tokenId, startTime, endTime);
        // } catch {
        //     _pause();
        // }
    }

    ///                                                          ///
    ///                        DROP UPGRADE                   ///
    ///                                                          ///

    /// @notice Ensures the caller is authorized to upgrade the contract
    /// @dev This function is called in `upgradeTo` & `upgradeToAndCall`
    /// @param _newImpl The new implementation address
    function _authorizeUpgrade(address _newImpl) internal view override onlyOwner {}
}
