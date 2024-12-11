// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { IPAssetRegistry } from "@storyprotocol/core/registries/IPAssetRegistry.sol";
import { ISPGNFT } from "@storyprotocol/periphery/interfaces/ISPGNFT.sol";
import { RegistrationWorkflows } from "@storyprotocol/periphery/workflows/RegistrationWorkflows.sol";
import { WorkflowStructs } from "@storyprotocol/periphery/lib/WorkflowStructs.sol";

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleNFT is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
    uint256 public _nextTokenId;

    //这里写入你的NFT metadata文件的地址
    string public baseURI = "https://jade-labour-hawk-866.mypinata.cloud/ipfs/QmUpS6ZvPUWPrKqiNJNomHLrAi2Rqa25xmo3Et8gjyoT21";

    constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable(msg.sender) {}

    function Mint_with_data(address to) public onlyOwner returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, baseURI);
        return tokenId;
    }

    function mint(address to) public onlyOwner returns (uint256) {
    
        uint256 tokenId = _nextTokenId++;
        _mint(to, tokenId);
        return tokenId;

    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }


    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}



contract IPARegistrarTest is Test {
    //输入你的地址在      address（这里输入） 不需要引号
    address public user = address();

    //这里输入你的NFT名字和缩写，在两个引号之间，删除内容填入自己的内容
    string public test_nft_name = "WEEWQEWQ";
    string public test_nft_sym = "DSADWDWA";

    // 在这个网站查看已经部署的合约接口 https://docs.story.foundation/docs/deployed-smart-contracts
    // Protocol Core - IPAssetRegistry
    IPAssetRegistry public immutable IP_ASSET_REGISTRY = IPAssetRegistry(0x28E59E91C0467e89fd0f0438D47Ca839cDfEc095);
    // Protocol Periphery - RegistrationWorkflows
    RegistrationWorkflows public immutable REGISTRATION_WORKFLOWS = RegistrationWorkflows(0xde13Be395E1cd753471447Cf6A656979ef87881c);

    SimpleNFT public SIMPLE_NFT;
    ISPGNFT public SPG_NFT;



    function setUp() public {
        // Create a new Simple NFT collection
        SIMPLE_NFT = new SimpleNFT(test_nft_name, test_nft_sym);
        // Create a new NFT collection via SPG
        SPG_NFT = ISPGNFT(
            REGISTRATION_WORKFLOWS.createCollection(
                ISPGNFT.InitParams({
                    name: test_nft_name,
                    symbol: test_nft_sym,
                    baseURI: "",
                    contractURI: "",
                    maxSupply: 100,
                    mintFee: 0,
                    mintFeeToken: address(0),
                    mintFeeRecipient: user,
                    owner: user,
                    mintOpen: true,
                    isPublicMinting: true
                })
            )
        );
    }

    /// @notice Mint an NFT and then register it as an IP Asset.
    function test_register() public {
        uint256 tokenId = SIMPLE_NFT.Mint_with_data(user);
        IP_ASSET_REGISTRY.register(block.chainid, address(SIMPLE_NFT), tokenId);

    }

}
