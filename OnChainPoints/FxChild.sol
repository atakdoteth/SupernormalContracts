// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/0xPolygon/fx-portal/blob/main/contracts/tunnel/FxBaseChildTunnel.sol";
import "./ISN.sol";


contract FxStateChildTunnel is FxBaseChildTunnel {
    address public SN_CONTRACT;

    uint256 public latestStateId;
    address public latestRootMessageSender;
    bytes public latestData;


    constructor(address _fxChild, address _SNContract) FxBaseChildTunnel(_fxChild) {
        setSNContract(_SNContract);
    }

    function _processMessageFromRoot(
        uint256 stateId,
        address sender,
        bytes memory data
    ) internal override validateSender(sender) {
        latestStateId = stateId;
        latestRootMessageSender = sender;
        latestData = data;

        ISN(SN_CONTRACT).processData(data);
    }

    function setSNContract(address _contract) internal{
        SN_CONTRACT = _contract;
    }

}