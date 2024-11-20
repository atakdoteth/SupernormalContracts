// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "solady/src/utils/LibString.sol";
import "erc721a-upgradeable/contracts/ERC721AUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "operator-filter-registry/src/upgradeable/DefaultOperatorFiltererUpgradeable.sol";

//author = atak.eth
contract Masterpass is ERC721AUpgradeable, DefaultOperatorFiltererUpgradeable, OwnableUpgradeable {
    string baseURI;


    bool public auctionEnded;
    uint256 public maxSupply;
    uint256 public winningAmount;
    mapping(address => uint256[]) public bidsOfWallet;

    event BidPlaced(address indexed from, uint256 indexed amount);
    event MetadataUpdate(uint256 _tokenId);

    function initialize(string memory name, string memory symbol) public initializerERC721A initializer {
        __ERC721A_init(name, symbol);
        __Ownable_init(msg.sender);
        __DefaultOperatorFilterer_init();

        maxSupply = 420;
    }

    //Auction

    function getBidCountOfWallet(address _wallet) public view returns (uint256) {
        return bidsOfWallet[_wallet].length;
    }

    function placeBid() external payable {
        require(!auctionEnded, "Auction has ended.");
        require(msg.value > 0, "Bid value must be greater than 0.");

        emit BidPlaced(msg.sender, msg.value);
        bidsOfWallet[msg.sender].push(msg.value);
    }

    function endAuction() external onlyOwner {
        require(!auctionEnded, "Auction has already ended.");

        auctionEnded = true;
    }

    function setWinningBid(uint256 _winningBid) external onlyOwner {
        winningAmount = _winningBid;
    }

    function refund() external {
        require(auctionEnded, "Auction hasnt ended yet");
        require(bidsOfWallet[msg.sender].length > 0, "You dont have any bids");
        uint256 totalRefund = calculateRefund(msg.sender);
        require(totalRefund > 0, "Your total refund is 0");
        delete bidsOfWallet[msg.sender];

        payable(msg.sender).transfer(totalRefund);
    }

    function calculateRefund(address _of) public view returns (uint256 refundTotal) {
        uint256 totalRefund;

        for (uint256 i; i < bidsOfWallet[_of].length;) {
            if (bidsOfWallet[_of][i] >= winningAmount) {
                totalRefund += bidsOfWallet[_of][i] - winningAmount;
            } else {
                totalRefund += bidsOfWallet[_of][i];
            }

            unchecked {
                ++i;
            }
        }

        return totalRefund;
    }

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
        emit MetadataUpdate(type(uint256).max);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId),"token doesnt exist");
        return string(abi.encodePacked(baseURI, LibString.toString(tokenId), ".json"));
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        super.setControllerAddress(newOwner);
        super.transferOwnership(newOwner);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override payable onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override payable onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId) public override payable onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function airdrop(address[] calldata wallets) external onlyOwner {
        if(!tradeable){
            setTradeable(true);
        }
        require(totalSupply() + wallets.length <= maxSupply, "This tx would exceed max supply");
        for (uint256 i; i < wallets.length;) {
            _mint(wallets[i], 1);
            unchecked {
                ++i;
            }
        }
        setTradeable(false);
    }

    function teamMint(address to, uint256 quantity) external onlyOwner {
        require(totalSupply() + quantity <= maxSupply, "This tx would exceed max supply");
        _mint(to, quantity);
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(address(this).balance > 0, "No balance to withdraw");
        require(amount > address(this).balance, "Amount is more than the balance on the contract");
        payable(msg.sender).transfer(amount);
    }
}
