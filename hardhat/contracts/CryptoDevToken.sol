// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
    //price of each cryptodev token
    uint256 public constant tokenPrice = 0.001 ether;
    //each NFT gives owner 10 tokens, gotta multiply those tokens for *(10^18) because of ERC tokens have smallest denomination of 10^-18,
    //so each token is 1*(10**18)
    uint256 public constant tokensPerNft = 10 * (10**18);
    //setting max supply at 10000
    uint256 public constant maxTotalSupply = 10000 * (10**18);
    //CryptoDevsNFT contract instance
    ICryptoDevs CryptoDevsNFT;
    //need to keep track of which tokens have been claimed
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD") {
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    //mints 'amount' number of CD token, requires that msg.value >= tokenPrice * amount
    function mint(uint256 amount) public payable {
        uint256 _requiredAmount = amount * tokenPrice;
        require(msg.value >= _requiredAmount, "Not enough Ether");
        uint256 amountDec = amount * (10**18);
        require(
            (totalSupply() + amountDec) <= maxTotalSupply,
            "Not enough supply available"
        );
        _mint(msg.sender, amountDec); //ERC20 contract internal function
    }

    function claim() public {
        address sender = msg.sender;
        uint256 balance = CryptoDevsNFT.balanceOf(sender);
        //if balance  == 0 revert
        require(balance > 0, "You dont own any CD NFTs");
        // need to keep track of unclaimed tokens
        uint256 amount = 0;
        for (uint256 i = 0; i < balance; i++) {
            //loop over sender balance and checks for unclaimed tokens
            uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);
            if (!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        //require at least 1 unclaimed token
        require(amount > 0, "You have already claimed your tokens");
        _mint(msg.sender, (amount * tokensPerNft));
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed transaction");
    }

    receive() external payable {}

    fallback() external payable {}
}
