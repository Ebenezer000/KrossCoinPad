pragma solidity >0.6.0;
//SPDX-License-Identifier: MIT

interface IERC20Token {
    function balanceOf(address who) external view returns (uint256);
    function allowance(address poolReciever, address spender) external  view returns (uint);
    function transfer(address to, uint amount) external  returns (bool ok);
    function transferFrom(address from, address to, uint amount) external returns (bool ok);
    function decimals() external returns (uint256);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
}
interface ERC20Token {
    function balanceOf(address who) external view returns (uint256);
    function allowance(address poolReciever, address spender) external  view returns (uint);
    function transfer(address to, uint amount) external  returns (bool ok);
    function transferFrom(address from, address to, uint amount) external returns (bool ok);
    function decimals() external returns (uint256);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
         {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
       {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}


contract KssIdo is Initializable{
  using SafeMath for uint256;
  IERC20Token public token;
  ERC20Token public Busd;
  uint256 public Price = 1;
  uint256 internal amount;
  uint256 public minBuy = 0;
  uint256 public busdRaised = tokenSold;
  uint256 public tokenSold;
  uint256 public Cap;
  address public poolReciever;
  uint saleAmount;
  

  mapping(address => mapping (address => uint256)) allowed;

  enum Stages {
        buyStage,
        Finished
    }

    Stages public stage = Stages.buyStage;


    modifier atStage(Stages _stage) {
        require(stage == _stage);
        _;
    }
    
    modifier transitionAfter() {
        _;
        pauseSale();
    }
    modifier transitionBefore() {
        _;
        restartSale();
    }
 //set token to sell with
 function Add_Busd(address _busdAddr) public {
    Busd = ERC20Token(_busdAddr);
 }
 
   //set token for sale
 function Add_Token(address _tokenAddr) public {
    token = IERC20Token(_tokenAddr);
 }
 //Set ido rate
 function setPrice(uint256 newPrice) public {
    Price = newPrice;
 }
 //setCap
 function setCap(uint256 newCap) public {
    Cap = newCap;
 }
 //setTaker
 function setTaker(address _reciever) public {
    poolReciever = _reciever;
 }
 
 //set minimum buy
 function setMinBuy(uint256 _minBuy) public{
     minBuy = _minBuy;
 }
 
 
 //change crowdsale stage to pause sale
 function pauseSale() public {
        stage = Stages(uint(stage) + 1);
 }
 //change crowdsale stage to continue sale
 function restartSale() public {
        stage = Stages(uint(stage) - 1);
}

 //remove Tokens remaining
 function tokenRemover()public{
         require( msg.sender == poolReciever);
         token.transfer(poolReciever,token.balanceOf(address(this)));
}
 //remove busd remaining
 function removeBusd()public{
         require(msg.sender == poolReciever);
         Busd.transfer(poolReciever,Busd.balanceOf(address(this)));
}

function Contribute (uint contributionAmount)public atStage(Stages.buyStage){
    require(contributionAmount > minBuy && contributionAmount < Cap);
    amount = (contributionAmount).mul(Price);
    Busd.transferFrom(msg.sender, address(this), amount);
    token.transfer(msg.sender, amount);
    tokenSold += amount;
}

function endSale()public{
    tokenRemover();
    removeBusd();
}

}