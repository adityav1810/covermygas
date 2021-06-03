// SPDX-License-Identifier: MIT
pragma abicoder v2;
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

contract CMG {
    address owner;
    IERC20 currencyToken;
    IERC721 NFToken;
    uint256 escrowCount;
    mapping(uint256 => escrow) public escrows;

    modifier restricted() {
        require(
            msg.sender == owner,
            "This function is restricted to the contract's owner"
        );
        _;
    }

    struct escrow {
        address seller;
        address buyer;
        uint256 tokenID;
        uint256 currencyAmount;
    }

    event EscrowMasterCreated(
        address indexed NFToken,
        address indexed currencyToken
    );

    event EscrowCreated(
        uint256 indexed escrowID,
        uint256 indexed tokenID,
        address seller,
        address buyer,
        uint256 currencyAmount
    );

    event EscrowCompleted(
        uint256 indexed escrowID,
        uint256 indexed tokenID,
        address seller,
        address buyer,
        uint256 currencyAmount
    );

    constructor(address _NFTAddress, address _TokenAddress) {
        NFToken = IERC721(_NFTAddress);
        currencyToken = IERC20(_TokenAddress);
        owner = msg.sender;
        escrowCount = 0;
        emit EscrowMasterCreated(_NFTAddress, _TokenAddress);
    }

    function createEscrow(
        address seller,
        address buyer,
        uint256 tokenID,
        uint256 currencyAmount
    ) public {
        require(
            NFToken.isApprovedForAll(msg.sender, address(this)),
            "NFT transfers not approved. Please approve this contract."
        );
        require(
            seller == msg.sender,
            "You cannot mark another account as the seller"
        );
        NFToken.safeTransferFrom(seller, address(this), tokenID);
        escrows[escrowCount] = escrow({
            seller: seller,
            buyer: buyer,
            tokenID: tokenID,
            currencyAmount: currencyAmount
        });
        escrowCount += 1;
        emit EscrowCreated(
            escrowCount - 1,
            tokenID,
            seller,
            buyer,
            currencyAmount
        );
    }

    function cancelEscrow(uint256 escrowID) external {
        escrow memory esc = escrows[escrowID];
        require(
            esc.seller == msg.sender,
            "Only the owner of Escrow can cancel it"
        );
        NFToken.safeTransferFrom(address(this), msg.sender, esc.tokenID);
        delete escrows[escrowID];
    }

    function completeEscrow(uint256 escrowID, uint256 currencyAmount) public {
        escrow memory esc = escrows[escrowID];
        require(
            esc.buyer == msg.sender,
            "Only the he designated buyer has can call this"
        );
        require(
            esc.currencyAmount == currencyAmount,
            "Offer amounts do no match"
        );
        require(
            currencyToken.allowance(msg.sender, address(this)) >=
                currencyAmount,
            "Your token allowance is not enough. Please call the approve function again."
        );
        currencyToken.transferFrom(msg.sender, esc.seller, currencyAmount);
        NFToken.safeTransferFrom(address(this), msg.sender, esc.tokenID);
        emit EscrowCompleted(
            escrowID,
            esc.tokenID,
            esc.seller,
            esc.buyer,
            esc.currencyAmount
        );
    }

    function getCreatedEscrows()
        public
        view
        returns (escrow[] memory createdEscrows)
    {
        escrow[] memory _createdEscrows = new escrow[](10); // Will only return a max of 10 escrows :/
        uint256 _count = 0;
        for (uint256 i = 0; i < escrowCount; i++) {
            escrow memory esc = escrows[i];
            if (esc.seller == msg.sender) {
                _createdEscrows[_count] = esc;
                _count++;
            }
        }
        return (_createdEscrows);
    }

    function getPendingEscrows()
        public
        view
        returns (escrow[] memory pendingEscrows)
    {
        escrow[] memory _pendingEscrows = new escrow[](10); // Will only return a max of 10 escrows :/
        uint256 _count = 0;
        for (uint256 i = 0; i < escrowCount; i++) {
            escrow memory esc = escrows[i];
            if (esc.buyer == msg.sender) {
                _pendingEscrows[_count] = esc;
                _count++;
            }
        }
        return (_pendingEscrows);
    }
}
