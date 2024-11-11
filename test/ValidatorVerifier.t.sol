// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import { Test } from "forge-std/Test.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { Vm } from "forge-std/Vm.sol";

import { SSZ } from "../src/SSZ.sol";
import { ValidatorVerifier } from "../src/ValidatorVerifier.sol";

contract ValidatorVerifierTest is Test {
    using stdJson for string;

    struct ProofJson {
        bytes32[] validatorProof;
        SSZ.Validator validator;
        uint64 validatorIndex;
        bytes32 blockRoot;
    }

    uint256 constant DENEB_ZERO_VALIDATOR_GINDEX = 798245441765376;

    address public constant BEACON_ROOTS =
        0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;

    ValidatorVerifier public verifier;
    ProofJson public proofJson;

    function setUp() public {
        string memory root = vm.projectRoot();
        string memory path =
            string.concat(root, "/test/fixtures/validator_proof.json");
        string memory json = vm.readFile(path);
        bytes memory data = json.parseRaw("$");
        proofJson = abi.decode(data, (ProofJson));
    }

    function test_ProveValidator() public {
        uint64 ts = 31337;

        verifier = new ValidatorVerifier(DENEB_ZERO_VALIDATOR_GINDEX);

        vm.mockCall(
            verifier.BEACON_ROOTS(),
            abi.encode(ts),
            abi.encode(proofJson.blockRoot)
        );

        verifier.proveValidator(
            proofJson.validatorProof,
            proofJson.validator,
            proofJson.validatorIndex,
            ts
        );
    }

    function test_ProveValidator_OnFork() public {
        uint64 ts = uint64(block.timestamp);

        bytes32 parentRoot = getParentBlockRoot(ts);
        assertEq(parentRoot, proofJson.blockRoot);

        verifier = new ValidatorVerifier(DENEB_ZERO_VALIDATOR_GINDEX);

        verifier.proveValidator(
            proofJson.validatorProof,
            proofJson.validator,
            proofJson.validatorIndex,
            ts
        );
    }
    function getParentBlockRoot(uint64 ts)
        internal
        view
        returns (bytes32 root)
    {
        (bool success, bytes memory data) =
            BEACON_ROOTS.staticcall(abi.encode(ts));

        if (!success || data.length == 0) {
            revert("No root found");
        }

        root = abi.decode(data, (bytes32));
    }
}
