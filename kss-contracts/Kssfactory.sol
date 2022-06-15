//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IERC20Token {
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function decimals() external returns (uint256);
}
contract CloneFactory {

  function createClone(address target) internal returns (address result) {
    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
      result := create(0, clone, 0x37)
    }
  }

  function isClone(address target, address query) internal view returns (bool result) {
    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
      mstore(add(clone, 0xa), targetBytes)
      mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

      let other := add(clone, 0x40)
      extcodecopy(query, other, 0, 0x2d)
      result := and(
        eq(mload(clone), mload(other)),
        eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
      )
    }
  }
}


contract Factory is CloneFactory {
     Child[] public children;
     address masterContract;
     constructor(address _masterContract){
         masterContract = _masterContract;
     }

     function createChild(address _tokenAddr,uint256 newPrice, uint256 _minBuy,
     uint256 newCap, address _reciever) external{
        Child child = Child(createClone(masterContract));
        child.Add_Token(_tokenAddr);
        child.setPrice(newPrice);
        child.setMinBuy(_minBuy);
        child.setTaker(_reciever);
        child.setCap(newCap);
        children.push(child);
     }

     function getChildren() external view returns(Child[] memory){
         return children;
     }
}

contract Child{
  IERC20Token public token;
  uint256 public Price;
  uint256 internal amount;
  uint256 public minBuy = 0;
  uint256 public bnbRaised;
  uint256 public tokenSold;
  uint256 public Cap;
  address payable public poolReciever;
    
    
    
    function Add_Token(address _tokenAddr) public {
    token = IERC20Token(_tokenAddr);
 }
 
 function setPrice(uint256 newPrice) public {
    Price = newPrice;
 }
 
 function setCap(uint256 newCap) public {
    Cap = newCap;
 }
 function setTaker(address _reciever) public {
    poolReciever = (payable(_reciever));
 }
 
 function setMinBuy(uint256 _minBuy) public{
     minBuy = _minBuy;
 }
 
}