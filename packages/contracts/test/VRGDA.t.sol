// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.22;

import { Token } from "../src/Token.sol";
import { Claim } from "../src/Claim.sol";
import { IToken } from "../src/interfaces/IToken.sol";
import { IClaim } from "../src/interfaces/IClaim.sol";
import { Descriptor } from "../src/Descriptor.sol";
import { Swap } from "../src/Swap.sol";
import { ISwap } from "../src/interfaces/ISwap.sol";
import { IDescriptor } from "../src/interfaces/IDescriptor.sol";
import { ERC1967Proxy } from "../src/proxy/ERC1967Proxy.sol";

contract VrgdaTest is Test {
    function setUp() public virtual {}
}
