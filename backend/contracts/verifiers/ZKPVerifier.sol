// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../lib/GenesisUtils.sol";
import "../lib/SpongePoseidon.sol";
import "../lib/Poseidon.sol";
import "../interfaces/ICircuitValidator.sol";
import "../interfaces/IZKPVerifier.sol";

contract ZKPVerifier is IZKPVerifier, Ownable {
    mapping(address => mapping(uint64 => bool)) public proofs;

    mapping(uint64 => ICircuitValidator.CircuitQuery) public requestQueries;
    mapping(uint64 => ICircuitValidator) public requestValidators;

    uint64[] internal _supportedRequests;

    event SubmitedRequest(address indexed user, bool indexed proofStatus);

    function submitZKPResponse(
        uint64 requestId,
        uint256[] calldata inputs
    ) public override returns (bool) {
        require(
            requestValidators[requestId] != ICircuitValidator(address(0)),
            "validator is not set for this request id"
        ); // validator exists
        require(requestQueries[requestId].queryHash != 0, "query is not set for this request id"); // query exists

        _beforeProofSubmit(requestId, inputs, requestValidators[requestId]);

        proofs[msg.sender][requestId] = true; // user provided a valid proof for request

        _afterProofSubmit(requestId, inputs, requestValidators[requestId]);
        return true;
    }

    function getZKPRequest(
        uint64 requestId
    ) public view override returns (ICircuitValidator.CircuitQuery memory) {
        return requestQueries[requestId];
    }

    function setZKPRequest(
        uint64 requestId,
        ICircuitValidator validator,
        uint256 schema,
        uint256 claimPathKey,
        uint256 operator,
        uint256[] calldata value
    ) public override onlyOwner returns (bool) {
        uint256 valueHash = SpongePoseidon.hash(value);
        // only merklized claims are supported (claimPathNotExists is false, slot index is set to 0 )
        uint256 queryHash = PoseidonUnit6L.poseidon(
            [schema, 0, operator, claimPathKey, 0, valueHash]
        );

        return
        setZKPRequestRaw(
            requestId,
            validator,
            schema,
            claimPathKey,
            operator,
            value,
            queryHash
        );
    }

    function setZKPRequestRaw(
        uint64 requestId,
        ICircuitValidator validator,
        uint256 schema,
        uint256 claimPathKey,
        uint256 operator,
        uint256[] calldata value,
        uint256 queryHash
    ) public override onlyOwner returns (bool) {
        if (requestValidators[requestId] == ICircuitValidator(address(0x00))) {
            _supportedRequests.push(requestId);
        }
        requestQueries[requestId].queryHash = queryHash;
        requestQueries[requestId].operator = operator;
        requestQueries[requestId].circuitId = validator.getCircuitId();
        requestQueries[requestId].claimPathKey = claimPathKey;
        requestQueries[requestId].schema = schema;
        requestQueries[requestId].value = value;
        requestValidators[requestId] = validator;
        return true;
    }

    function getSupportedRequests() public view returns (uint64[] memory arr) {
        return _supportedRequests;
    }

    /**
     * @dev Hook that is called before any proof response submit
     */
    function _beforeProofSubmit(
        uint64 requestId,
        uint256[] memory inputs,
        ICircuitValidator validator
    ) internal virtual {}

    /**
     * @dev Hook that is called after any proof response submit
     */
    function _afterProofSubmit(
        uint64 requestId,
        uint256[] memory inputs,
        ICircuitValidator validator
    ) internal virtual {}
}
