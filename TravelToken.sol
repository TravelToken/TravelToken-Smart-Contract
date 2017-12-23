pragma solidity ^0.4.15;

import "./SafeMath.sol";
import "./Ownable.sol";
import './ERC20.sol';
import "./NonZero.sol";
 


contract TravelToken is ERC20, Ownable, NonZero {

    using SafeMath for uint;


/////////////////////// TOKEN INFORMATION ///////////////////////
    string public constant name = "TravelToken";
    string public constant symbol = "TRIP";
    
    uint8 public decimals = 3;
    
    // Mapping to keep user's balances
    mapping (address => uint256) balances;
    // Mapping to keep user's allowances
    mapping (address => mapping (address => uint256)) allowed;

/////////////////////// VARIABLE INITIALIZATION ///////////////////////
    
    // Allocation for the TravelToken Team
    uint256 public TravelTokenTeamSupply;
    // Reserve supply
    uint256 public ReserveSupply;
    // Amount of TripCoin for the presale
    uint256 public presaleSupply;

    uint256 public icoSupply;
    // Community incentivisation supply
    uint256 public incentivisingEffortsSupply;
    // Crowdsale End Timestamp
    uint256 public presaleStartsAt;
    uint256 public presaleEndsAt;
    uint256 public icoStartsAt;
    uint256 public icoEndsAt;
    
    // TravelToken team address
    address public TripCoinTeamAddress;
    // Reserve address
    address public ReserveAddress;
    // Community incentivisation address
    address public incentivisingEffortsAddress;

    // Flag keeping track of presale status. Ensures functions can only be called once
    bool public presaleFinalized = false;
    // Flag keeping track of crowdsale status. Ensures functions can only be called once
    bool public icoFinalized = false;
    // Amount of wei currently raised
    uint256 public weiRaised = 0;

/////////////////////// EVENTS ///////////////////////

    // Event called when crowdfund is done
    event icoFinalized(uint tokensRemaining);
    // Event called when presale is done
    event PresaleFinalized(uint tokensRemaining);
    // Emitted upon crowdfund being finalized
    event AmountRaised(address beneficiary, uint amountRaised);
    // Emmitted upon purchasing tokens
    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);

/////////////////////// MODIFIERS ///////////////////////

 

    // Ensure only crowdfund can call the function
    modifier onlypresale() {
        require(msg.sender == owner);
        _;
    }
    modifier onlyico() {
        require(msg.sender == owner);
        _;
    }

/////////////////////// ERC20 FUNCTIONS ///////////////////////

    // Transfer
    function transfer(address _to, uint256 _amount) returns (bool success) {
        require(balanceOf(msg.sender) >= _amount);
        addToBalance(_to, _amount);
        decrementBalance(msg.sender, _amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    // Transfer from one address to another (need allowance to be called first)
    function transferFrom(address _from, address _to, uint256 _amount) returns (bool success) {
        require(allowance(_from, msg.sender) >= _amount);
        decrementBalance(_from, _amount);
        addToBalance(_to, _amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        Transfer(_from, _to, _amount);
        return true;
    }

    // Approve another address a certain amount of TripCoin
    function approve(address _spender, uint256 _value) returns (bool success) {
        require((_value == 0) || (allowance(msg.sender, _spender) == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    // Get an address's TripCoin allowance
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // Get the TripCoin balance of any address
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

/////////////////////// TOKEN FUNCTIONS ///////////////////////

    // Constructor
    function TC() {
        presaleStartsAt; 
        presaleEndsAt; 
        icoStartsAt;
        icoEndsAt;                                              
           

        totalSupply = 200000000000;                                                   // 100% - 200m
        TravelTokenTeamSupply = 20000000000;                                              // 10%
        ReserveSupply = 60000000000;                                                // 30% 
        incentivisingEffortsSupply = 20000000000;                                    // 10% 
        icosSupply = 60000000000;                                                // 30%
        presaleSupply = 40000000000;                                                    // 20%
       
       
        TravelTokenTeamAddress              // TravelToken Team Address
        ReserveAddress             // Reserve Address
        incentivisingEffortsAddress ;   // Community incentivisation address

        addToBalance(incentivisingEffortsAddress, incentivisingEffortsSupply);     
        addToBalance(ReserveAddress, ReserveSupply); 
        addToBalance(owner, presaleSupply.add(icoSupply));
        
        addToBalance(TripCoinTeamAddress, TripCoinTeamSupply); 
    }

    

    // Function for the presale to transfer tokens
    function transferFromPresale(address _to, uint256 _amount) onlyOwner nonZeroAmount(_amount) nonZeroAddress(_to) returns (bool success) {
        require(balanceOf(owner) >= _amount);
        decrementBalance(owner, _amount);
        addToBalance(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }
      // Function for the ico to transfer tokens
    function transferFromIco(address _to, uint256 _amount) onlyOwner nonZeroAmount(_amount) nonZeroAddress(_to) returns (bool success) {
        require(balanceOf(owner) >= _amount);
        decrementBalance(owner, _amount);
        addToBalance(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }
    function getRate() public constant returns (uint price) {
        if (now > presaleStartsAt && now < presaleEndsAt ) {
           return 2400; 
        } else if (now > icoStartsAt && now < icoEndsAt) {
           return 2000; 
        } 
    }       
    
    TravelToken public token;
    
     function buyTokens(address _to) nonZeroAddress(_to) nonZeroValue payable {
        uint256 weiAmount = msg.value;
        uint256 tokens = weiAmount.mul(getRate());
        weiRaised = weiRaised.add(weiAmount);
        if (now > presaleStartsAt && now < presaleEndsAt ) {
           token.transferFromPresale(_to,tokens); 
        } else if (now > icoStartsAt && now < icoEndsAt) {
          token.transferFromIco(_to,tokens); 
        } 
        owner.transfer(msg.value);
        TokenPurchase(_to, weiAmount, tokens);
    
        
      
    }
    
     function () payable {
        buyTokens(msg.sender);
    }
   

    

    // Add to balance
    function addToBalance(address _address, uint _amount) internal {
    	balances[_address] = balances[_address].add(_amount);
    }

    // Remove from balance
    function decrementBalance(address _address, uint _amount) internal {
    	balances[_address] = balances[_address].sub(_amount);
    }
}
