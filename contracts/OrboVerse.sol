// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

// OrboVerse is the coolest bar in town. You come in with some Orbo, and leave with more! The longer you stay, the more Orbo you get.
//
// This contract handles swapping to and from xOrbo, OrboSwap's staking token.
contract OrboVerse is ERC20("OrboVerse", "xORBO"){
    using SafeMath for uint256;
    IERC20 public orbo;

    // Define the Orbo token contract
    constructor(IERC20 _orbo) public {
        orbo = _orbo;
    }

    // Enter the bar. Pay some ORBOs. Earn some shares.
    // Locks Orbo and mints xOrbo
    function enter(uint256 _amount) public {
        // Gets the amount of Orbo locked in the contract
        uint256 totalOrbo = orbo.balanceOf(address(this));
        // Gets the amount of xOrbo in existence
        uint256 totalShares = totalSupply();
        // If no xOrbo exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalOrbo == 0) {
            _mint(msg.sender, _amount);
        } 
        // Calculate and mint the amount of xOrbo the Orbo is worth. The ratio will change overtime, as xOrbo is burned/minted and Orbo deposited + gained from fees / withdrawn.
        else {
            uint256 what = _amount.mul(totalShares).div(totalOrbo);
            _mint(msg.sender, what);
        }
        // Lock the Orbo in the contract
        orbo.transferFrom(msg.sender, address(this), _amount);
    }

    // Leave the bar. Claim back your ORBOs.
    // Unlocks the staked + gained Orbo and burns xOrbo
    function leave(uint256 _share) public {
        // Gets the amount of xOrbo in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of Orbo the xOrbo is worth
        uint256 what = _share.mul(orbo.balanceOf(address(this))).div(totalShares);
        _burn(msg.sender, _share);
        orbo.transfer(msg.sender, what);
    }
}
