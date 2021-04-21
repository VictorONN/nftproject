// contracts/GameItem.sol

pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract adventureNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //token payments
    mapping(address => uint256) public playerAmounts;

    // this marks an item in IPFS as "forsale"
    mapping(bytes32 => bool) public forSale;
    mapping(bytes32 => uint256) public uriToTokenId;

    constructor(bytes32[] memory assetsForSale) ERC721("adventureNFT", "ANFT") {
        _baseURI("https://ipfs.io/ipfs/");
        for (uint256 i = 0; i < assetsForSale.length; i++) {
            forSale[assetsForSale[i]] = true;
        }
    }

    function transferTokens(uint256 amount, address _nipToken) public {
        require(
            IERC20(_nipToken).transferFrom(msg.sender, address(this), amount),
            "TRANSFER FAILED"
        );
        playerAmounts[msg.sender] += amount;
    }

    function createAdventureNFT(string memory tokenURI)
        public
        returns (uint256)
    {
        require(playerAmounts[msg.sender] >= 10000, "INADEQUATE TOKENS");
        bytes32 uriHash = keccak256(abi.encodePacked(tokenURI));
        //make sure they are only minting something that is marked "forsale"
        require(forSale[uriHash], "NOT FOR SALE");
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        uriToTokenId[uriHash] = newItemId;

        return newItemId;
    }
}

// contract YourCollectible is ERC721 {

//   using Counters for Counters.Counter;
//   Counters.Counter private _tokenIds;

//   constructor(bytes32[] memory assetsForSale) public ERC721("YourCollectible", "YCB") {
//     _setBaseURI("https://ipfs.io/ipfs/");
//     for(uint256 i=0;i<assetsForSale.length;i++){
//       forSale[assetsForSale[i]] = true;
//     }
//   }

//   //this marks an item in IPFS as "forsale"
//   mapping (bytes32 => bool) public forSale;
//   //this lets you look up a token by the uri (assuming there is only one of each uri for now)
//   mapping (bytes32 => uint256) public uriToTokenId;

//   function mintItem(string memory tokenURI)
//       public
//       returns (uint256)
//   {
//       bytes32 uriHash = keccak256(abi.encodePacked(tokenURI));

//       //make sure they are only minting something that is marked "forsale"
//       require(forSale[uriHash],"NOT FOR SALE");
//       forSale[uriHash]=false;

//       _tokenIds.increment();

//       uint256 id = _tokenIds.current();
//       _mint(msg.sender, id);
//       _setTokenURI(id, tokenURI);

//       uriToTokenId[uriHash] = id;

//       return id;
//   }
// }
