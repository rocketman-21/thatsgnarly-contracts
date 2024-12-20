// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.22;

import { console2 } from "forge-std/console2.sol";
import { Script } from "forge-std/Script.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { ERC1967Proxy } from "../src/proxy/ERC1967Proxy.sol";

import { MaxHeap } from "../src/MaxHeap.sol";
import { CultureIndex } from "../src/CultureIndex.sol";
import { ICultureIndex } from "../src/interfaces/ICultureIndex.sol";
import { IMintHouse } from "../src/interfaces/IMintHouse.sol";
import { MintHouse } from "../src/MintHouse.sol";

contract DeployContracts is Script {
    using Strings for uint256;

    // gnars token on base
    address token = 0x880Fb3Cf5c6Cc2d7DFC13a993E839a9411200C17;

    address gnarsDAO = 0x72aD986ebAc0246D2b3c565ab2a1ce3a14cE6f88;

    address zoraCreatorFixedPriceSaleStrategy = 0x04E2516A2c207E84a1839755675dfd8eF6302F0a;

    address zora1155 = 0xF9a6470C704E391a64d1565ba4d50ad9C456b1dC;

    address cultureIndexImpl;
    address maxHeapImpl;
    address mintHouseImpl;

    address cultureIndexProxy;
    address maxHeapProxy;
    address mintHouseProxy;

    address initialOwner;

    function run() public {
        uint256 chainID = vm.envUint("CHAIN_ID");
        uint256 key = vm.envUint("PRIVATE_KEY");
        initialOwner = vm.envAddress("INITIAL_OWNER");

        console2.log("Initial Owner Address:", initialOwner);

        address deployerAddress = vm.addr(key);

        vm.startBroadcast(deployerAddress);

        cultureIndexImpl = deployCultureIndexImpl();
        maxHeapImpl = deployMaxHeapImpl();
        mintHouseImpl = deployMintHouseImpl();

        cultureIndexProxy = deployCultureIndexProxy();
        maxHeapProxy = deployMaxHeapProxy();
        mintHouseProxy = deployMintHouseProxy();

        initializeProxies();

        vm.stopBroadcast();

        writeDeploymentDetailsToFile(chainID);
    }

    function deployCultureIndexProxy() private returns (address) {
        return address(new ERC1967Proxy(cultureIndexImpl, ""));
    }

    function deployMaxHeapProxy() private returns (address) {
        return address(new ERC1967Proxy(maxHeapImpl, ""));
    }

    function deployMintHouseProxy() private returns (address) {
        return address(new ERC1967Proxy(mintHouseImpl, ""));
    }

    function initializeProxies() private {
        CultureIndex(cultureIndexProxy).initialize({
            _initialOwner: initialOwner,
            _dropperAdmin: mintHouseProxy,
            _gnarsToken: token,
            _maxHeap: maxHeapProxy,
            _cultureIndexParams: ICultureIndex.CultureIndexParams({
                quorumVotesBPS: 0,
                minVotingPowerToVote: 1,
                minVotingPowerToCreate: 0,
                tokenVoteWeight: 1e18 * 10,
                pointsVoteWeight: 0,
                name: "That's Gnarly",
                description: "Become a part of Gnars DAO history, onchain.",
                checklist: "",
                template: "",
                requiredMediaType: ICultureIndex.MediaType.NONE,
                requiredMediaPrefix: ICultureIndex.RequiredMediaPrefix.MIXED,
                pieceMaximums: ICultureIndex.PieceMaximums({
                    name: 1e2,
                    description: 1e3,
                    image: 64_000,
                    text: 100_000,
                    animationUrl: 1_000
                })
            })
        });

        // initialize maxheap
        MaxHeap(maxHeapProxy).initialize({ _initialOwner: initialOwner, _admin: cultureIndexProxy });

        MintHouse(mintHouseProxy).initialize({
            _initialOwner: initialOwner,
            _cultureIndex: cultureIndexProxy,
            _zoraCreator1155: zora1155,
            _gnarsDAO: gnarsDAO,
            _zoraCreatorFixedPriceSaleStrategy: zoraCreatorFixedPriceSaleStrategy,
            _mintParams: IMintHouse.MintParams({ price: 0, duration: 7 days, interval: 1 days })
        });
    }

    function deployMintHouseImpl() private returns (address) {
        return address(new MintHouse());
    }

    function deployCultureIndexImpl() private returns (address) {
        return address(new CultureIndex());
    }

    function deployMaxHeapImpl() private returns (address) {
        return address(new MaxHeap());
    }

    function writeDeploymentDetailsToFile(uint256 chainID) private {
        string memory filePath = string(abi.encodePacked("deploys/", chainID.toString(), ".txt"));

        vm.writeFile(filePath, "");
        vm.writeLine(filePath, string(abi.encodePacked("CultureIndex: ", addressToString(cultureIndexImpl))));
        vm.writeLine(filePath, string(abi.encodePacked("MaxHeap: ", addressToString(maxHeapImpl))));
        vm.writeLine(filePath, string(abi.encodePacked("MintHouse: ", addressToString(mintHouseImpl))));
        vm.writeLine(filePath, string(abi.encodePacked("CultureIndex Proxy: ", addressToString(cultureIndexProxy))));
        vm.writeLine(filePath, string(abi.encodePacked("MaxHeap Proxy: ", addressToString(maxHeapProxy))));
        vm.writeLine(filePath, string(abi.encodePacked("MintHouse Proxy: ", addressToString(mintHouseProxy))));
    }

    function addressToString(address _addr) private pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(uint160(_addr)) / (2 ** (8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(abi.encodePacked("0x", string(s)));
    }

    function char(bytes1 b) private pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}
