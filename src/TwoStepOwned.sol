// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

/// @title Two Step Owned
/// @author jtriley.eth
/// @dev two-step ownership transfer.
abstract contract TwoStepOwned {
    /// @dev logged when ownership transfer starts.
    /// @param previous previous owner.
    /// @param next next owner.
    event StartOwnerTransfer(address indexed previous, address indexed next);

    /// @dev logged when ownership transfer is complete.
    event CompleteOwnerTransfer();

    /// @dev thrown when the caller is not the owner.
    error NotOwner();

    /// @dev thrown when the caller is not the next owner.
    error NotNextOwner();

    /// @dev contract owner.
    address public owner;

    /// @dev next contract owner (when transferring).
    address public next;

    modifier onlyOwner() {
        if (owner != msg.sender) revert NotOwner();
        _;
    }

    /// @dev starts ownership transfer. throws if caller is not owner.
    /// @param nextOwner next owner.
    function startOwnerTransfer(address nextOwner) public {
        address currentOwner = owner;
        if (currentOwner != msg.sender) revert NotOwner();
        next = nextOwner;
        emit StartOwnerTransfer(currentOwner, nextOwner);
    }

    /// @dev completes ownership transfer. throws if caller is not next owner.
    function completeOwnerTransfer() public {
        address nextOwner = next;
        if (nextOwner != msg.sender) revert NotNextOwner();
        owner = nextOwner;
        emit CompleteOwnerTransfer();
    }
}
