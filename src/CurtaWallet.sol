// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {ICurta, IPuzzle} from "./interfaces/ICurta.sol";
import {TwoStepOwned} from "./TwoStepOwned.sol";
import "./Constants.sol";

/// @title Curta Wallet
/// @author jtriley.eth
/// @dev two-step transfer smart wallet for cheap curta challenge solving.
contract CurtaWallet is TwoStepOwned {
    struct Call {
        uint256 gas;
        address target;
        uint256 value;
        bytes payload;
    }

    /// @dev logged when customFallback is set.
    /// @param previous Previous custom fallback.
    /// @param next Next custom fallback.
    event SetCustomFallback(address indexed previous, address indexed next);

    /// @dev thrown when a call fails that is not allowed to fail.
    error CallFail();

    /// @dev calls the Curta.solve method with direct inputs. throws if Curta.solve reverts or if
    ///      the caller is not the owner.
    /// @param puzzleId id of the puzzle.
    /// @param solution solution value to the puzzle.
    function solve(uint32 puzzleId, uint256 solution) public payable onlyOwner {
        assembly {
            mstore(SELECTOR_PTR, shl(SELECTOR_SHIFT, SOLVE_SELECTOR))
            mstore(ARG0_PTR, puzzleId)
            mstore(ARG1_PTR, solution)
            if iszero(
                call(
                    gas(),
                    CURTA,
                    callvalue(),
                    SOLVE_ARG_PTR,
                    SOLVE_ARG_LEN,
                    SOLVE_RET_PTR,
                    SOLVE_RET_LEN
                )
            ) {
                mstore(CALL_FAIL_PTR, shl(SELECTOR_SHIFT, CALL_FAIL_SELECTOR))
                return(CALL_FAIL_PTR, CALL_FAIL_LEN)         
            }
        }
    }

    /// @dev calls a bundle of external calls with explicit gas and callvalues, then calls
    ///      Curta.solve. throws if Curta.solve reverts, the caller is not the owner, or if any call
    ///      reverts AND the throwOnFail variable is set to true.
    /// @dev explicit gas and callvalue enables challenges relying on these values, the throwOnFail
    ///      value enables challenges that rely on intermediate failures.
    /// @param throwOnFail true if any call failure should throw.
    /// @param puzzleId id of the puzzle.
    /// @param solution solution of the puzzle.
    function multiStepSolve(
        Call[] calldata,
        bool throwOnFail,
        uint32 puzzleId,
        uint256 solution
    ) public payable onlyOwner {
        assembly {
            let balanceBefore := selfbalance()
            let callsLeft := calldataload(CALLS_LEFT_CD_PTR)
            let callOffsetPtr := CALL_STRUCT_OFFSET_CD_PTR
            let anyFails

            for {} 1 {} {
                if iszero(callsLeft) { break }

                let callStruct := add(callOffsetPtr, calldataload(callOffsetPtr))
                let payloadLen := calldataload(add(callStruct, CALL_STRUCT_PAYLOAD_LEN_OFFSET))

                calldatacopy(CALL_ARG_PTR, add(callStruct, CALL_STRUCT_PAYLOAD_START_OFFSET), payloadLen)
                anyFails := or(
                    anyFails,
                    iszero(
                        call(
                            calldataload(callStruct),
                            calldataload(add(callStruct, CALL_STRUCT_TARGET_OFFSET)),
                            calldataload(add(callStruct, CALL_STRUCT_VALUE_OFFSET)),
                            CALL_ARG_PTR,
                            payloadLen,
                            CALL_RET_PTR,
                            CALL_RET_LEN
                        )
                    )
                )

                callsLeft := sub(callsLeft, CALLS_LEFT_DECREMENT)
                callOffsetPtr := add(callOffsetPtr, CALL_STRUCT_OFFSET_CD_PTR_INCREMENT)
            }

            mstore(SELECTOR_PTR, shl(SELECTOR_SHIFT, SOLVE_SELECTOR))
            mstore(ARG0_PTR, puzzleId)
            mstore(ARG1_PTR, solution)
            if or(
                iszero(
                    call(
                        gas(),
                        CURTA,
                        callvalue(),
                        SOLVE_ARG_PTR,
                        SOLVE_ARG_LEN,
                        SOLVE_RET_PTR,
                        SOLVE_RET_LEN
                    )
                ),
                and(throwOnFail, anyFails)
             ) {
                mstore(CALL_FAIL_PTR, shl(SELECTOR_SHIFT, CALL_FAIL_SELECTOR))
                revert(CALL_FAIL_PTR, CALL_FAIL_LEN)
            }
        }
    }

    /// @dev sets custom fallback address, bc someone, somewhere, is going to use this wallet, and
    ///      someone else, somewhere else, is going to make a cheeky little challenge that tries to
    ///      force you to do some kind of custom execution in the fallback. and when that day comes,
    ///      that someone, somewhere, is going to be thankful they have this on hand. unless, of
    ///      course, that someone else, somewhere else, is aware that this requires a storage load
    ///      followed by a delegatecall and restricts the gas to this step to an amount less than a
    ///      cold storage load and cold delegatecall. and if that is the case there is nothing i can
    ///      do to help you. godspeed, someone, somewhere, and someone else, somewhere else. i hope
    ///      one day you can make amends.
    /// @dev throws if caller is not the owner.
    /// @dev dev. DEV. yes. you. do not. and i mean DO NOT. use an address with untrusted code.
    /// @param nextCustomFallback next custom fallback address.
    function setCustomFallback(address nextCustomFallback) public onlyOwner {
        assembly {
            let previousCustomFallback := sload(CUSTOM_FALLBACK_SLOT)
            sstore(CUSTOM_FALLBACK_SLOT, nextCustomFallback)
            log3(
                CUSTOM_FALLBACK_EVENT_PTR,
                CUSTOM_FALLBACK_EVENT_LEN,
                CUSTOM_FALLBACK_EVENT_HASH,
                previousCustomFallback,
                nextCustomFallback
            )
        }
    }

    /// @dev 
    receive() external payable {
        assembly {
            let customFallback := sload(CUSTOM_FALLBACK_SLOT)
            if iszero(customFallback) {
                mstore(
                    FALLBACK_SELECTOR_PTR,
                    shr(SELECTOR_SHIFT, calldataload(FALLBACK_SELECTOR_CD_PTR))
                )
                return(FALLBACK_SELECTOR_PTR, FALLBACK_SELECTOR_LEN)
            }

            calldatacopy(FALLBACK_ARG_PTR, FALLBACK_SELECTOR_CD_PTR, calldatasize())
            let success := delegatecall(
                gas(),
                customFallback,
                FALLBACK_ARG_PTR,
                calldatasize(),
                FALLBACK_RET_PTR,
                FALLBACK_RET_LEN
            )
            returndatacopy(FALLBACK_RET_PTR, FALLBACK_RET_PTR, returndatasize())

            if success {
                return(FALLBACK_RET_PTR, returndatasize())
            }
            revert(FALLBACK_RET_PTR, returndatasize())
        }
    }
}
