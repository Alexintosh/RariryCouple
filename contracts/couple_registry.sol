// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./interfaces/IERC721.sol";
import "./interfaces/rarity_interfaces.sol";
import "./interfaces/rarity_structs.sol";

contract couple_registry {

    rarity constant rm = rarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);

    uint256 proposalsCount = 0;
    uint256 relationshipsCount = 0;

    mapping( uint256 => Proposal ) public proposals;
    mapping( uint256 => Relationship ) public relationships;
    mapping( uint => uint ) public partner; // person to relationship id mapping
    
    struct Proposal {
        uint timestamp;
        uint initiatorId; // the one who starts
        uint receiverId;
        bool accepted;
        // consider have an expiry date
    }
    
    struct Relationship {
        uint startTimestamp;
        uint endTimestamp;
        uint summoner1;
        uint summoner2;
    }

    event Proposed(uint indexed proposalId, uint indexed initiatorId, uint receiverId);

    function _isApprovedOrOwner(uint _summoner) internal view returns (bool) {
        return rm.getApproved(_summoner) == msg.sender || rm.ownerOf(_summoner) == msg.sender;
    }

    function propose(uint _initiator, uint _receiver) external returns (uint) {
        require(_isApprovedOrOwner(_initiator), '!owner');
        require(partner[_initiator] == 0, 'already in a relationship');
        uint proposalId = proposalsCount;
        Proposal storage prop = proposals[proposalId];
        prop.initiatorId = _initiator;
        prop.receiverId = _receiver;
        prop.timestamp = block.timestamp;
        prop.accepted = false;
        proposalsCount += 1;
        emit Proposed(proposalId, _initiator, _receiver);
        return proposalId;
    }

    function getProposal(uint _id) external view returns (Proposal memory prop ) {
        return proposals[_id];
    }

    function getRelationship(uint _id) external view returns (Relationship memory rel ) {
        return relationships[_id];
    }

    function getRelationshipOf(uint _id) external view returns (Relationship memory rel ) {
        return relationships[partner[_id]];
    }

    function acceptProposal(uint _id) external {
        require(_isApprovedOrOwner(proposals[_id].receiverId), '!owner');
        require(partner[proposals[_id].receiverId] == 0, 'already in a relationship');

        uint relationshipId = relationshipsCount;
        Proposal storage prop = proposals[_id];
        prop.accepted = true;

        //update mappings
        partner[proposals[_id].receiverId] = relationshipId;
        partner[proposals[_id].initiatorId] = relationshipId;

        Relationship storage relationship = relationships[relationshipId];
        relationship.startTimestamp = block.timestamp;
        relationship.endTimestamp = 0;
        relationship.summoner1 = proposals[_id].initiatorId;
        relationship.summoner2 = proposals[_id].receiverId;

        relationshipsCount += 1;
    }
    

}
