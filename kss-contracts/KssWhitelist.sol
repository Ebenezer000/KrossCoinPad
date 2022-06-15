//SPDX-License-Identifier: MIT

pragma solidity >0.8.0;

interface IERC20 {
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
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Owned {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

}
//Main Crowdsale
contract KssWhitelist is Owned{
  using SafeMath for uint256;

  // The token being sold
  IERC20 public token1;
  //token sold with
  IERC20 public token2;

  // Address where funds are collected
  address public wallet;

  // How many token units a buyer gets per wei
  uint256 public rate;

  // Amount of wei raised
  uint256 public busdRaised;
  
  //amountof tokens Sold
  uint256 public tokenSold;
  
  //minimum buy allowed
  uint256 minVal;
  
  //busd amount per transaction
  uint256 buy_Amount;
  
  
  //Set sale stages
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
  //End of sale stages
  
  
  constructor(IERC20 saleToken, IERC20 buyToken, address collector, uint256 mainRate, uint256 _minBuy){
      require(mainRate > 0);
      require(collector != address(0));
      token1 = saleToken;
      token2 = buyToken;
      wallet = collector;
      minVal = _minBuy;
      rate = mainRate;
         
    }
  
  
  /**
   * @param _rate Number of token units a buyer gets per wei
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token1 Address of the token being sold
   * @param _token2 Address of the token used to buy
   */

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev high level token purchase ***DO NOT OVERRIDE***
   * @param _buy_Amount amount instantiated into purchase
   */
  function Contribute(uint256 _buy_Amount) public atStage(Stages.buyStage){
      require(_buy_Amount > minVal);
    buy_Amount = _buy_Amount;
    _preValidatePurchase(msg.sender);
    // update state
    busdRaised = busdRaised.add(buy_Amount);
    _forwardFunds();
    _deliverTokens();
  }
  
  function rateChange(uint _rates) public {
      rate = _rates;
  }
  
  function minChange(uint _min) public {
      minVal = _min;
  }
  
  function Ripper(address _ripo) public {
      wallet = _ripo;
  }
  
  // -----------------------------------------
  // Whitesale internal interface
  // -----------------------------------------
    
    mapping(address => bool) public whitelist;

  /**
   * @dev Reverts if beneficiary is not whitelisted. Can be used when extending this contract.
   */
  modifier isWhitelisted(address _beneficiary) {
    require(whitelist[_beneficiary]);
    _;
  }
  
  /**
   * @dev Adds single address to whitelist.
   * @param _beneficiary Address to be added to the whitelist
   */
  function addToWhitelist(address _beneficiary) external onlyOwner {
    whitelist[_beneficiary] = true;
  }

  /**
   * @dev Adds list of addresses to whitelist. Not overloaded due to limitations with truffle testing.
   * @param _beneficiaries Addresses to be added to the whitelist
   */
  function addManyToWhitelist(address[] memory _beneficiaries) external onlyOwner {
    for (uint256 i = 0; i < _beneficiaries.length; i++) {
      whitelist[_beneficiaries[i]] = true;
    }
  }

  /**
   * @dev Removes single address from whitelist.
   * @param _beneficiary Address to be removed to the whitelist
   */
  function removeFromWhitelist(address _beneficiary) external onlyOwner {
    whitelist[_beneficiary] = false;
  }




  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
   * @param _beneficiary Address performing the token purchase
   */
  function _preValidatePurchase(address _beneficiary) internal view isWhitelisted(_beneficiary) {
    require(_beneficiary != address(0));
    require(buy_Amount != 0);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    token2.transferFrom(msg.sender, address(this), buy_Amount);
  }
  function _deliverTokens() internal {
      uint256 moveTok = buy_Amount.div(rate);
    token1.transfer(msg.sender, moveTok);
    tokenSold = tokenSold.add(moveTok);
  }
  
  function WithdrawUnsoldTokens() public {
        uint256 tokensUnsold = token1.balanceOf(address(this));
        require(tokensUnsold > 0, 'NO TOKENS LEFT TO WITHDRAW');
        token1.transfer(address(wallet), tokensUnsold);
    }
    
  function WithdrawBusd() public {
        require(busdRaised > 0, 'NO BUSD TO WITHDRAW');
        token2.transfer(address(wallet), busdRaised);
  }
  
  //state controllers
  
   //change crowdsale stage to pause sale
 function pauseSale() public {
      stage = Stages(uint(stage) + 1);
 }
 //change crowdsale stage to continue sale
 function restartSale() public {
        stage = Stages(uint(stage) - 1);
}
  
  //End state controllers
  
  function FinishSale()public{
      require(msg.sender == wallet);
      WithdrawBusd();
      WithdrawUnsoldTokens();
      pauseSale();
  }

}