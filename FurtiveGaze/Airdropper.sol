// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract FurtiveGazeAirdropper is Ownable{
    
    uint256 public tokenID = 1;
    IERC721 FurtiveGazeContract;

    constructor(address _FurtiveGazeContractAddress) Ownable(msg.sender) {
        FurtiveGazeContract = IERC721(_FurtiveGazeContractAddress);
    }
    

    function setFGContract(address _FurtiveGazeContractAddress) external onlyOwner{
        FurtiveGazeContract = IERC721(_FurtiveGazeContractAddress);
    }

    function airdropTokens(address[] calldata wallets, uint256[] calldata amounts) external{
        require(wallets.length == amounts.length,"Array lengths dont match");

        for(uint i = 0; i < wallets.length; i++){
            address currentWallet = wallets[i];
            uint currentQuantity = amounts[i];
            for(uint j = 0; j < currentQuantity; j++){
                FurtiveGazeContract.transferFrom(msg.sender, currentWallet, tokenID);
                tokenID++;
            }
        }
    }
}
