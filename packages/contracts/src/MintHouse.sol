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
import { IZoraCreator1155 } from "./interfaces/IZoraCreator1155.sol";
import { ICreatorRoyaltiesControl } from "./interfaces/ICreatorRoyaltiesControl.sol";
import { IZoraCreatorFixedPriceSaleStrategy } from "./interfaces/IZoraCreatorFixedPriceSaleStrategy.sol";
import { IMinter1155 } from "./interfaces/IMinter1155.sol";

import { UUPS } from "./proxy/UUPS.sol";

contract MintHouse is IMintHouse, UUPS, PausableUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    // The minimum price accepted in a mint
    uint96 public price;

    // The duration of a single mint in seconds
    uint64 public duration;

    // The minimum time between each mint
    uint256 public interval;

    // The active mint
    IMintHouse.Mint public mint;

    // The contract holding art pieces to be minted
    ICultureIndex public cultureIndex;

    // The Zora Creator ERC1155 contract
    IZoraCreator1155 public zoraCreator1155;

    // The GnarsDAO address to receive protocol rewards
    address public gnarsDAO;

    // The fixed price sale strategy contract from Zora
    address public zoraCreatorFixedPriceSaleStrategy;

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
     * @param _zoraCreator1155 The address of the Zora Creator ERC1155 contract.
     * @param _gnarsDAO The address of the GnarsDAO.
     * @param _zoraCreatorFixedPriceSaleStrategy The address of the Zora Creator Fixed Price Sale Strategy.
     * @param _mintParams The mint params for mints.
     */
    function initialize(
        address _initialOwner,
        address _cultureIndex,
        address _zoraCreator1155,
        address _gnarsDAO,
        address _zoraCreatorFixedPriceSaleStrategy,
        MintParams calldata _mintParams
    ) external initializer {
        if (_cultureIndex == address(0)) revert ADDRESS_ZERO();
        if (_initialOwner == address(0)) revert ADDRESS_ZERO();
        if (_zoraCreator1155 == address(0)) revert ADDRESS_ZERO();
        if (_gnarsDAO == address(0)) revert ADDRESS_ZERO();
        if (_zoraCreatorFixedPriceSaleStrategy == address(0)) revert ADDRESS_ZERO();

        __Pausable_init();
        __ReentrancyGuard_init();
        __Ownable_init(_initialOwner);

        _pause();

        // set mint params
        price = _mintParams.price;
        duration = _mintParams.duration;
        interval = _mintParams.interval;

        // set contracts
        cultureIndex = ICultureIndex(_cultureIndex);
        zoraCreator1155 = IZoraCreator1155(_zoraCreator1155);
        zoraCreatorFixedPriceSaleStrategy = _zoraCreatorFixedPriceSaleStrategy;
        gnarsDAO = _gnarsDAO;
    }

    /**
     * @notice Create a new mint.
     */
    function createNewMint() external override nonReentrant whenNotPaused {
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
     * @notice Unpause the Mint house.
     * @dev This function can only be called by the owner when the
     * contract is paused. If required, this function will start a new mint.
     */
    function unpause() external override onlyOwner {
        _unpause();
    }

    /**
     * @notice Set the mint price.
     * @dev Only callable by the owner.
     */
    function setPrice(uint96 _price) external override onlyOwner {
        price = _price;

        emit PriceUpdated(_price);
    }

    /**
     * @notice Set the duration of the mint.
     * @dev Only callable by the owner.
     * @param _duration New duration for the mint.
     */
    function setDuration(uint64 _duration) external onlyOwner {
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
        // ensure that `interval` has passed since the last mint
        // startTime of last mint + interval < now
        if (mint.startTime + interval > block.timestamp) revert DROP_NOT_COMPLETED();

        // Use try/catch to handle potential failure
        try cultureIndex.dropTopVotedPiece() returns (ICultureIndex.ArtPieceCondensed memory artPiece) {
            // Only 1 creator supported for now!
            address creator = artPiece.creators[0].creator;

            // create mint with referral to DAO
            uint256 tokenId = zoraCreator1155.setupNewTokenWithCreateReferral(
                artPiece.tokenURI,
                // open edition
                18446744073709551615,
                gnarsDAO
            );

            // update royalties to creator
            zoraCreator1155.updateRoyaltiesForToken(
                tokenId,
                ICreatorRoyaltiesControl.RoyaltyConfiguration({
                    royaltyRecipient: creator,
                    royaltyBPS: 500,
                    royaltyMintSchedule: 0
                })
            );

            // add permission for sale strategy
            zoraCreator1155.addPermission(
                tokenId,
                zoraCreatorFixedPriceSaleStrategy,
                zoraCreator1155.PERMISSION_BIT_MINTER()
            );

            uint64 startTime = uint64(block.timestamp);
            uint64 endTime = startTime + duration;

            // call sale contract and update sales config
            zoraCreator1155.callSale(
                tokenId,
                IMinter1155(zoraCreatorFixedPriceSaleStrategy),
                abi.encodeCall(
                    IZoraCreatorFixedPriceSaleStrategy.setSale,
                    (
                        tokenId /* tokenId */,
                        IZoraCreatorFixedPriceSaleStrategy.SalesConfig({
                            saleStart: startTime /* saleStart */,
                            saleEnd: endTime /* saleEnd */,
                            maxTokensPerAddress: 0 /* maxTokensPerAddress - 0 means unlimited */,
                            pricePerToken: price /* pricePerToken */,
                            fundsRecipient: creator /* fundsRecipient */
                        })
                    )
                )
            );

            mint = Mint({ tokenId: tokenId, startTime: startTime, endTime: endTime, price: price });

            emit MintCreated(tokenId, startTime, endTime, price);
        } catch {
            _pause();
        }
    }

    ///                                                          ///
    ///                        DROP UPGRADE                   ///
    ///                                                          ///

    /// @notice Ensures the caller is authorized to upgrade the contract
    /// @dev This function is called in `upgradeTo` & `upgradeToAndCall`
    /// @param _newImpl The new implementation address
    function _authorizeUpgrade(address _newImpl) internal view override onlyOwner {}
}
