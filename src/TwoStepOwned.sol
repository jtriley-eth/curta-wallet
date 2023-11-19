// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

contract TwoStepOwned {
    event StartOwnerTransfer(address indexed previous, address indexed next);
    event CompleteOwnerTransfer();

    error NotOwner();
    error NotNextOwner();

    address public owner;
    address public next;

    modifier onlyOwner() {
        if (owner != msg.sender) revert NotOwner();
        _;
    }

    function startOwnerTransfer(address nextOwner) public {
        address currentOwner = owner;
        if (currentOwner != msg.sender) revert NotOwner();
        next = nextOwner;
        emit StartOwnerTransfer(currentOwner, nextOwner);
    }

    function completeOwnerTransfer() public {
        address nextOwner = next;
        if (nextOwner != msg.sender) revert NotNextOwner();
        owner = nextOwner;
        emit CompleteOwnerTransfer();
    }
}
