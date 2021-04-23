// contracts/GameItem.sol

pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract adventureNFT is ERC721URIStorage {
    IERC20 catnip;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //users deposit tokens to be used to mint NFTs
    mapping(address => uint256) public playerAmounts;

    // this marks an item in IPFS as "forsale"
    mapping(bytes32 => bool) public forSale;
    mapping(bytes32 => uint256) public uriToTokenId;

    constructor(bytes32[] memory assetsForSale, address catnipAddress)
        ERC721("adventureNFT", "ANFT")
    {
        _baseURI();
        catnip = IERC20(catnipAddress);
        for (uint256 i = 0; i < assetsForSale.length; i++) {
            forSale[assetsForSale[i]] = true;
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    function transferTokens(uint256 amount) public returns (uint256) {
        require(
            catnip.transferFrom(msg.sender, address(this), amount),
            "TRANSFER FAILED"
        );
        playerAmounts[msg.sender] += amount;
        return playerAmounts[msg.sender];
    }

    function createAdventureNFT(string memory tokenURI)
        public
        returns (uint256)
    {
        bytes32 uriHash = keccak256(abi.encodePacked(tokenURI));
        //make sure they are only minting something that is marked "forsale"
        require(forSale[uriHash], "NOT FOR SALE");
        require(playerAmounts[msg.sender] >= 10000, "INADEQUATE TOKENS");
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        uriToTokenId[uriHash] = newItemId;

        return newItemId;
    }
}
