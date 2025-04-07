// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract CryptoGiftCard {
    address public owner;
    IERC20 public token;

    struct GiftCard {
        uint256 value;
        bool redeemed;
    }

    mapping(uint256 => GiftCard) public giftCards;
    uint256 public nextGiftCardId;

    event GiftCardIssued(address indexed recipient, uint256 indexed giftCardId, uint256 value);
    event GiftCardRedeemed(address indexed redeemer, uint256 indexed giftCardId, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can execute this");
        _;
    }

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
    }

    // Issue a new gift card to the recipient
    function issueGiftCard(address recipient, uint256 value) external onlyOwner {
        require(value > 0, "Value must be greater than 0");

        uint256 giftCardId = nextGiftCardId;
        nextGiftCardId++;

        giftCards[giftCardId] = GiftCard({
            value: value,
            redeemed: false
        });

        emit GiftCardIssued(recipient, giftCardId, value);
    }

    // Redeem a gift card and transfer the value to the user's address
    function redeemGiftCard(uint256 giftCardId) external {
        GiftCard storage card = giftCards[giftCardId];
        require(card.value > 0, "Invalid gift card");
        require(!card.redeemed, "Gift card already redeemed");

        // Mark as redeemed
        card.redeemed = true;

        // Transfer the gift card value to the caller
        require(token.transfer(msg.sender, card.value), "Token transfer failed");

        emit GiftCardRedeemed(msg.sender, giftCardId, card.value);
    }

    // Get the balance of a gift card
    function getGiftCardBalance(uint256 giftCardId) external view returns (uint256) {
        return giftCards[giftCardId].value;
    }

    // Owner can withdraw any tokens from the contract
    function withdrawTokens(uint256 amount) external onlyOwner {
        require(token.transfer(owner, amount), "Token transfer failed");
    }
}

