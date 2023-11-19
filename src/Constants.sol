// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

// yo
// uhh
// hmm

// selector bit shift amount
uint256 constant SELECTOR_SHIFT = 0xe0;

// that juicy curta addy
address constant CURTA = 0x6bC8D9e5e9d436217B88De704a9F307;

// external call selector and argument pointers
uint256 constant SELECTOR_PTR = 0x00;
uint256 constant ARG0_PTR = 0x04;
uint256 constant ARG1_PTR = 0x24;

// Curta.solve helpers
uint256 constant SOLVE_SELECTOR = 0x31468f06;
uint256 constant SOLVE_ARG_PTR = 0x00;
uint256 constant SOLVE_ARG_LEN = 0x44;
uint256 constant SOLVE_RET_PTR = 0x00;
uint256 constant SOLVE_RET_LEN = 0x00;

// call failure error helpers
uint256 constant CALL_FAIL_SELECTOR = 0x12fcf496;
uint256 constant CALL_FAIL_PTR = 0x00;
uint256 constant CALL_FAIL_LEN = 0x04;

// calls left helpers
uint256 constant CALLS_LEFT_CD_PTR = 0x84;
uint256 constant CALLS_LEFT_DECREMENT = 0x01;

// call struct offset helpers
uint256 constant CALL_STRUCT_OFFSET_CD_PTR = 0xa4;
uint256 constant CALL_STRUCT_OFFSET_CD_PTR_INCREMENT = 0x20;

// call struct helpers
uint256 constant CALL_STRUCT_TARGET_OFFSET = 0x20;
uint256 constant CALL_STRUCT_VALUE_OFFSET = 0x40;
uint256 constant CALL_STRUCT_PAYLOAD_LEN_OFFSET = 0x60;
uint256 constant CALL_STRUCT_PAYLOAD_START_OFFSET = 0x80;

// ext call helpers
uint256 constant CALL_ARG_PTR = 0x00;
uint256 constant CALL_RET_PTR = 0x00;
uint256 constant CALL_RET_LEN = 0x00;
uint256 constant CALL_OFFSET = 0x20;

// customFallback helpers
uint256 constant CUSTOM_FALLBACK_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
uint256 constant CUSTOM_FALLBACK_EVENT_HASH = 0x6f6fccf8aa9dc41c3248190529460c6505d836e61aacd63f6177904859318fec;
uint256 constant CUSTOM_FALLBACK_EVENT_PTR = 0x00;
uint256 constant CUSTOM_FALLBACK_EVENT_LEN = 0x00;

// fallback helpers
uint256 constant FALLBACK_SELECTOR_CD_PTR = 0x00;
uint256 constant FALLBACK_SELECTOR_PTR = 0x00;
uint256 constant FALLBACK_SELECTOR_LEN = 0x20;
uint256 constant FALLBACK_ARG_PTR = 0x00;
uint256 constant FALLBACK_RET_PTR = 0x00;
uint256 constant FALLBACK_RET_LEN = 0x00;
