// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract SNPointsUpgradeable is ERC20Upgradeable {
    mapping(uint256 => bool) public migrated;
    mapping(uint256 => uint256) public lastTransferredDate;
    mapping(uint256 => uint256) public claimedPointsOfToken;
    //updates with approx. 20 minutes of delay
    mapping(uint256 => address) public ownerOfToken;

    function initialize() public initializer {
        isOperator[msg.sender] = true;
        __ERC20_init("SNPoints", "SNP");
    }

    function processData(bytes memory data) public onlyOperator {
        uint256 tokenID;
        address newTokenOwner;
        bool isMigration;
        (tokenID, newTokenOwner, isMigration) = abi.decode(data, (uint256, address, bool));

        if (isMigration) {
            if (migrated[tokenID] == false) {
                changeLastTransferredDate(tokenID, block.timestamp);
            }
            migrated[tokenID] = true;
        } else {
            address previousOwner = ownerOfToken[tokenID];

            if (!(previousOwner == address(0x0)) && !(previousOwner == newTokenOwner)) {
                uint256 remainingBalanceOfPreviousOwner = balanceOf(previousOwner);
                if (remainingBalanceOfPreviousOwner > claimedPointsOfToken[tokenID]) {
                    burnBalanceOfAccount(previousOwner, claimedPointsOfToken[tokenID]);
                } else {
                    burnBalanceOfAccount(previousOwner, remainingBalanceOfPreviousOwner);
                }
                changeLastTransferredDate(tokenID, block.timestamp);
            }
        }

        ownerOfToken[tokenID] = newTokenOwner;
    }

    function setOwnersAndTimestamps(
        uint256[] memory tokenIDs,
        address[] memory accounts,
        uint256[] memory timeStamps
    ) public onlyOperator {
        require(tokenIDs.length == accounts.length && tokenIDs.length == timeStamps.length, "Array lengths dont match");
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            uint256 tokenID = tokenIDs[i];
            migrated[tokenID] = true;
            changeLastTransferredDate(tokenID, timeStamps[i]);
            ownerOfToken[tokenID] = accounts[i];
        }
    }

    function calculateUnclaimedPoints(uint256[] memory tokenIDs) public view returns (uint256 totalPoints) {
        uint256 total;
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            uint256 tokenID = tokenIDs[i];
            if (migrated[tokenID]) {
                total += (_calculatePointsOfToken(tokenID) - claimedPointsOfToken[tokenID]);
            }
        }
        return total;
    }

    function calculateTotalPoints(uint256[] calldata tokenIDs) external view returns(uint256 totalPoints) {
        uint256 total;
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            uint256 tokenID = tokenIDs[i];
            if (migrated[tokenID]) {
                total += _calculatePointsOfToken(tokenID);
            }
        }
        return total;
    }


    function _calculatePointsOfToken(uint256 tokenID) internal view returns (uint256 point) {
        uint256 passedTimeFromLastTransfer = block.timestamp - lastTransferredDate[tokenID];
        return (passedTimeFromLastTransfer / 86400);
    }

    function changeLastTransferredDate(uint256 tokenID, uint256 _newDate) internal {
        lastTransferredDate[tokenID] = _newDate;
        claimedPointsOfToken[tokenID] = 0;
    }

    function claimPointsOfTokens(uint256[] memory tokenIDs, address account) public {
        uint256 pointsToClaim;
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            uint256 tokenID = tokenIDs[i];
            require(
                ownerOfToken[tokenID] == account,
                "This address doesnt own at least 1 of the tokens or state havent synced yet. Wait 20 minutes."
            );
            uint256 unclaimedPointsAmountOfToken = (_calculatePointsOfToken(tokenID) - claimedPointsOfToken[tokenID]);
            claimedPointsOfToken[tokenID] += unclaimedPointsAmountOfToken;
            pointsToClaim += unclaimedPointsAmountOfToken;
        }
        require(pointsToClaim > 0,"You dont have any tokens to claim");
        _mint(account, pointsToClaim);
    }

    function airdropTokens(address[] calldata accounts, uint256[] calldata amounts) external onlyOperator {
        require(accounts.length == amounts.length, "Array lengths dont match");
        for (uint256 i = 0; i < accounts.length; ++i) {
            _mint(accounts[i], amounts[i]);
        }
    }
}
