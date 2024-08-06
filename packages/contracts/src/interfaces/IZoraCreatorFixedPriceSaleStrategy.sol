// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/// @title Interface for ZoraCreatorFixedPriceSaleStrategy
/// @notice A basic interface for the ZoraCreatorFixedPriceSaleStrategy contract
interface IZoraCreatorFixedPriceSaleStrategy {
    struct SalesConfig {
        uint64 saleStart;
        uint64 saleEnd;
        uint64 maxTokensPerAddress;
        uint96 pricePerToken;
        address fundsRecipient;
    }

    /// @notice Sets the sale config for a given token
    /// @param tokenId The token ID to set the sale config for
    /// @param salesConfig The sales configuration to set
    function setSale(uint256 tokenId, SalesConfig memory salesConfig) external;
}
