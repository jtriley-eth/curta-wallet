// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {ICurta} from "./interfaces/ICurta.sol";
import {TwoStepOwned} from "./TwoStepOwned.sol";

contract CurtaWallet is TwoStepOwned {
    struct Call {
        uint256 gas;
        address target;
        uint256 value;
        bytes payload;
    }

    error CallFail();

    ICurta internal constant curta = ICurta(address(0));

    function solve(uint32 puzzleId, uint256 solution) public payable onlyOwner {
        assembly {
            mstore(0x00, shl(0xe0, 0x31468f06))
            mstore(0x04, puzzleId)
            mstore(0x24, solution)
            if iszero(call(gas(), curta, 0x00, 0x44, 0x00, 0x00)) {
                mstore(0x00, shl(0xe0, 0x12fcf496))
                return(0x00, 0x04)         
            }
        }
    }

    function multiStepSolve(
        Call[] calldata calls,
        uint32 puzzleId,
        uint256 solution,
        bool throwOnFail
    ) public payable onlyOwner {
        assembly {
            let callsLeft := calldataload(0x84)
            let callOffsetPtr := 0xa4
            let anyFails

            for {} 1 {} {
                if iszero(callsLeft) { break; }

                let callData := add(callOffsetPtr, calldataload(callOffsetPtr))
                let payloadLen := calldataload(add(callData, 0x80))

                calldatacopy(0x00, add(callData, 0xa0), payloadLen)
                anyFails := or(
                    anyFails,
                    iszero(
                        call(
                            calldataload(callData),
                            calldataload(add(callData, 0x20))
                            calldataload(add(callData, 0x40))
                            0x00,
                            payloadLen,
                            0x00,
                            0x00
                        )
                    )
                )

                callsLeft := sub(callsLeft, 1)
                callOffsetPtr := add(callOffsetPtr, 0x20)
            }

            mstore(0x00, shl(0xe0, 0x31468f06))
            mstore(0x04, puzzleId)
            mstore(0x24, solution)
            anyFails := or(anyFails, iszero(call(gas(), curta, 0x00, 0x44, 0x00, 0x00)))

            if and(throwOnFail, anyFails) {
                mstore(0x00, shl(0xe0, 0x12fcf496))
                return(0x00, 0x04)
            }
        }
    }

    receive() external payable {
        assembly {
            mstore(0, shr(252, calldataload(0)))
            return(0, 32)
        }
    }
}

/*
0x0000 : 0xe0a996e2
0x0004 : 0000000000000000000000000000000000000000000000000000000000000080    // calls_offset
0x0024 : 0000000000000000000000000000000000000000000000000000000000000007    // puzzle_id
0x0044 : 0000000000000000000000000000000000000000000000000000000000000008    // solution
0x0064 : 0000000000000000000000000000000000000000000000000000000000000001    // throw_on_fail
0x0084 : 0000000000000000000000000000000000000000000000000000000000000002    // calls_length
0x00a4 : 0000000000000000000000000000000000000000000000000000000000000040    // calls_0_offset // asm { calls.offset }
0x00c4 : 0000000000000000000000000000000000000000000000000000000000000100    // calls_1_offset
0x00e4 : 0000000000000000000000000000000000000000000000000000000000000001    // calls_0_target // asm { calls[0] }
0x0104 : 0000000000000000000000000000000000000000000000000000000000000002    // calls_0_value
0x0124 : 0000000000000000000000000000000000000000000000000000000000000003    // calls_0_gas
0x0144 : 0000000000000000000000000000000000000000000000000000000000000080    // calls_0_payload_offset
0x0164 : 0000000000000000000000000000000000000000000000000000000000000004    // calls_0_payload_length
0x0184 : aabbccdd00000000000000000000000000000000000000000000000000000000    // calls_0_payload_start
0x01a4 : 0000000000000000000000000000000000000000000000000000000000000004    // calls_1_target // asm { calls[1] }
0x01c4 : 0000000000000000000000000000000000000000000000000000000000000005    // calls_1_value
0x01e4 : 0000000000000000000000000000000000000000000000000000000000000006    // calls_1_gas
0x0204 : 0000000000000000000000000000000000000000000000000000000000000080    // calls_1_payload_offset
0x0224 : 0000000000000000000000000000000000000000000000000000000000000004    // calls_1_payload_length
0x0244 : eeffaabb00000000000000000000000000000000000000000000000000000000    // calls_1_payload_start
*/
