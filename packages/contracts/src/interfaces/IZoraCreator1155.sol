// SPDX-License-Identifier: MIT

/*


             ░░░░░░░░░░░░░░              
        ░░▒▒░░░░░░░░░░░░░░░░░░░░        
      ░░▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░      
    ░░▒▒▒▒░░░░░░░░░░░░░░    ░░░░░░░░    
   ░▓▓▒▒▒▒░░░░░░░░░░░░        ░░░░░░░    
  ░▓▓▓▒▒▒▒░░░░░░░░░░░░        ░░░░░░░░  
  ░▓▓▓▒▒▒▒░░░░░░░░░░░░░░    ░░░░░░░░░░  
  ░▓▓▓▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░  
  ░▓▓▓▓▓▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░  
   ░▓▓▓▓▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░  
    ░░▓▓▓▓▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░    
    ░░▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░░▒▒▒▒▒░░    
      ░░▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░      
          ░░▓▓▓▓▓▓▓▓▓▓▓▓▒▒░░░          

               OURS TRULY,

 */

/**
 * @title Interface for ZoraCreator1155
 * @notice This interface has been modified to remove interface extensions and events.
 */
pragma solidity ^0.8.22;

import { IMinter1155 } from "./IMinter1155.sol";
import { ICreatorRoyaltiesControl } from "./ICreatorRoyaltiesControl.sol";

/// @notice Main interface for the ZoraCreator1155 contract
/// @author @iainnash / @tbtstl
interface IZoraCreator1155 {
    /// @notice Used to store individual token data
    struct TokenData {
        string uri;
        uint256 maxSupply;
        uint256 totalMinted;
    }

    function PERMISSION_BIT_ADMIN() external returns (uint256);

    /// @notice This user role allows for only mint actions to be performed
    function PERMISSION_BIT_MINTER() external returns (uint256);

    /// @notice This user role allows for only managing sales configurations
    function PERMISSION_BIT_SALES() external returns (uint256);

    /// @notice This user role allows for only managing metadata configuration
    function PERMISSION_BIT_METADATA() external returns (uint256);

    /// @notice This user role allows for only withdrawing funds and setting funds withdraw address
    function PERMISSION_BIT_FUNDS_MANAGER() external returns (uint256);

    /// @notice Used to label the configuration update type
    enum ConfigUpdate {
        OWNER,
        FUNDS_RECIPIENT,
        TRANSFER_HOOK
    }

    function setOwner(address newOwner) external;

    function owner() external view returns (address);

    /// @notice Mint tokens and payout rewards given a minter contract, minter arguments, and rewards arguments
    /// @param minter The minter contract to use
    /// @param tokenId The token ID to mint
    /// @param quantity The quantity of tokens to mint
    /// @param rewardsRecipients The addresses of rewards arguments - rewardsRecipients[0] = mintReferral, rewardsRecipients[1] = platformReferral
    /// @param minterArguments The arguments to pass to the minter
    function mint(
        IMinter1155 minter,
        uint256 tokenId,
        uint256 quantity,
        address[] calldata rewardsRecipients,
        bytes calldata minterArguments
    ) external payable;

    function adminMint(address recipient, uint256 tokenId, uint256 quantity, bytes memory data) external;

    function burnBatch(address user, uint256[] calldata tokenIds, uint256[] calldata amounts) external;

    /// @notice Contract call to setupNewToken
    /// @param tokenURI URI for the token
    /// @param maxSupply maxSupply for the token, set to 0 for open edition
    function setupNewToken(string memory tokenURI, uint256 maxSupply) external returns (uint256 tokenId);

    function setupNewTokenWithCreateReferral(
        string calldata newURI,
        uint256 maxSupply,
        address createReferral
    ) external returns (uint256);

    function getCreatorRewardRecipient(uint256 tokenId) external view returns (address);

    function updateTokenURI(uint256 tokenId, string memory _newURI) external;

    function updateContractMetadata(string memory _newURI, string memory _newName) external;

    // Public interface for `setTokenMetadataRenderer(uint256, address) has been deprecated.

    function contractURI() external view returns (string memory);

    function assumeLastTokenIdMatches(uint256 tokenId) external;

    function updateRoyaltiesForToken(
        uint256 tokenId,
        ICreatorRoyaltiesControl.RoyaltyConfiguration memory royaltyConfiguration
    ) external;

    /// @notice Set funds recipient address
    /// @param fundsRecipient new funds recipient address
    function setFundsRecipient(address payable fundsRecipient) external;

    /// @notice Allows the create referral to update the address that can claim their rewards
    function updateCreateReferral(uint256 tokenId, address recipient) external;

    function addPermission(uint256 tokenId, address user, uint256 permissionBits) external;

    function removePermission(uint256 tokenId, address user, uint256 permissionBits) external;

    function isAdminOrRole(address user, uint256 tokenId, uint256 role) external view returns (bool);

    function getTokenInfo(uint256 tokenId) external view returns (TokenData memory);

    function reduceSupply(uint256 tokenId, uint256 newMaxSupply) external;

    function callRenderer(uint256 tokenId, bytes memory data) external;

    function callSale(uint256 tokenId, IMinter1155 salesConfig, bytes memory data) external;

    function mintFee() external view returns (uint256);

    /// @notice Withdraws all ETH from the contract to the funds recipient address
    function withdraw() external;

    /// @notice Returns the current implementation address
    function implementation() external view returns (address);
}