// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ZkConnectLib.sol";

struct ProjectVote {
    uint8 projectId;
    uint256 proofId;
}

/**
 * @title ZkBallotBox
 */
contract ZkBallotBox is ZkConnect {
    bytes16 public immutable GROUP_ID;

    mapping(uint8 => uint) public votesByProject;
    mapping(uint256 => ProjectVote) public votesByUserId;

    // uint public startTime;
    // uint public endTime;

    event Vote(uint8 projectId, uint256 userId, uint256 proofId);

    constructor(
        // uint _startTime,
        // uint _endTime,
        bytes16 groupId,
        bytes16 appId
    ) ZkConnect(appId) {
        // startTime = _startTime;
        // endTime = _endTime;
        GROUP_ID = groupId;
    }

    function vote(bytes memory zkConnectRes, uint8 projectId) public {
        // require(block.timestamp >= startTime, "VOTING_NOT_STARTED");
        // require(block.timestamp <= endTime, "VOTING_ENDED");

        uint256 userId;
        uint256 proofId;
        
        (userId, proofId) = getUserIdAndProofId(zkConnectRes, projectId);

        require(votesByUserId[userId].projectId == 0, "USER_ALREADY_VOTED");

        votesByProject[projectId] = votesByProject[projectId] + 1;
        votesByUserId[userId].projectId = projectId;
        votesByUserId[userId].proofId = proofId;

        emit Vote(projectId, userId, proofId);
    }

    function clearVote(bytes memory zkConnectRes) public {
        vote(zkConnectRes, 0);
    }

    function getUserIdAndProofId(
        bytes memory zkConnectRes,
        uint8 projectId
    ) private returns (uint256, uint256) {
        ZkConnectVerifiedResult memory result = verify({
            responseBytes: zkConnectRes,
            authRequest: buildAuth({authType: AuthType.ANON}),
            claimRequest: buildClaim({groupId: GROUP_ID}),
            messageSignatureRequest: abi.encode(projectId)
        });
        uint256 userId = result.verifiedAuths[0].userId;
        uint256 proofId = result.verifiedClaims[0].proofId;

        return (userId, proofId);
    }
}
