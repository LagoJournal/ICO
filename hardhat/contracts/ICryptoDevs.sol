// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICryptoDevs {
    // Retuns tokenId owned by 'owner' at given 'index' of its token
    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256 tokenId);

    // returns number of tokens in 'owner' account
    function balanceOf(address owner) external view returns (uint256 balance);
}
