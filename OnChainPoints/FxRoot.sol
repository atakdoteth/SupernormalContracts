// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/0xPolygon/fx-portal/blob/main/contracts/tunnel/FxBaseRootTunnel.sol";

contract FxStateRootTunnel is FxBaseRootTunnel {
    bytes public latestData;
    mapping(address => bool) isOperator;

    constructor(address _checkpointManager, address _fxRoot) FxBaseRootTunnel(_checkpointManager, _fxRoot) {
        isOperator[msg.sender] = true;
    }

    modifier onlyOperator{
        require(isOperator[msg.sender], "Only operator allowed");
        _;
    }

    function setOperator(address _operator, bool _isOperator) public onlyOperator{
        isOperator[_operator] = _isOperator;
    }

    function _processMessageFromChild(bytes memory data) internal override {
        latestData = data;
    }

    function sendMessageToChild(uint256 tokenID, address newOwner, bool isMigration) external onlyOperator{
        _sendMessageToChild(abi.encode(tokenID,newOwner,isMigration));
    }

}