pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../interfaces/rarity_interfaces.sol";
import "../rarity_base.sol";

/**
TODO
- [ ] EIP-165 Support
- [ ] Consider ERC-1155 Batch Transfer, changes balance, maybe not worth it
 */
contract RarityVerse is ERC721, rarity_base {

    rarity constant rm = rarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    string constant public name = "Rarity Land";
    string constant public symbol = "RL";

    mapping(string => Land) public rarityverse;
    mapping(uint => Land[]) public landRegistry; //Summoner => Land

    struct Land {
        uint256 x;
        uint256 y;
        bool discovered;
        uint discoveredBy; //Summoner id
    }

    function discover(uint _summoner, uint256 x, uint256 y) external {
        require(_isApprovedOrOwner(_initiator), '!owner');
        require(wasDiscovered(x, x) == false, 'already discovered');
        
        Land storage _land = rarityverse[_get(x, y)];
        _land.discovered = true;
        _land.discoveredBy = _summoner;
        landRegistry[_summoner].push(_land);

        // _safeMint(_msgSender() );
    }

    function wasDiscovered(uint256 x, uint256 y) external view {
        return rarityverse[_get(x, y)].discovered;
    }

    /// @dev get string helper
    function _gs(uint256 x, uint256 y) external pure {
        return string(abi.encodePacked(toString(x), ",", toString(y)));
    }

    function travel(uint256 summoner,uint256 new_x,uint256 new_y) external {}
    function getLandPopulation() external view returns (uint256) {}
    function setLandFee() external {}
    function getLandFee() external {}
    function  getSummonerCoordinates() external {}
    
    function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT license https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

}