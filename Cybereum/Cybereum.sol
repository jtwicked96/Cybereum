pragma solidity ^0.4.19;

import './IERC202.sol';
import './SafeMath.sol';

contract Cybereum is IERC202 {
    
    using SafeMath for uint256;     
    
    uint public _totalSupply = 0;
    
    string public constant symbol = "CYB";
    string public constant name = "Cybereum";
    uint8 public constant decimals = 18;
    
    // 1 ether = 1000 CYB
    uint256 public constant RATE = 1000;
    
    address public owner;
    
    mapping(address => uint256) balances; //creating a mapping to store balance
    mapping(address => mapping(address => uint256)) allowed; //mapping being mapped to an address that is given permission to spend the funds, which is then mapped to how much they are able to spend
    
    function () payable {
        createTokens(); //calls createTokens, when ether is sent to the contract address, it will be added to owners balance and send the amounting CYB to the sending address
    }
    
    function Cybereum() {
        owner = msg.sender;
    }
    
    function createTokens() payable {
        require(msg.value > 0);
        
        uint256 tokens = msg.value.mul(RATE); //variable (tokens) that equals the amount of ether * the RATE
        balances[msg.sender] = balances[msg.sender].add(tokens); //add the tokens to the balance of the sending address
        _totalSupply = _totalSupply.add(tokens);
        
        owner.transfer(msg.value); //transfer the ether sent to the contract, to the owner of the contract. (If this fails it will actually throw an exception and roll the transaction back) )
    }
    
    function totalSupply() constant returns (uint256 totalSupply) {
        return _totalSupply;
    }
    
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner]; //return the balance of an address
    }
    
    function transfer(address _to, uint256 _value) returns (bool success) {
        require(                            //requiring certain conditions to be met
            balances[msg.sender] >= _value //making sure whatever is being transferred out actually exists in balances
            && _value > 0                   //make sure that value is greater than zero
        );
        balances[msg.sender] = balances[msg.sender].sub(_value); //start of adjusting math operations to prevent buffer overflow with .sub & .add instead of increment operators    
        balances[_to] = balances[_to].add(_value); 
        Transfer(msg.sender, _to, _value);  //from msg.sender to _value
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(
            allowed[_from][msg.sender] >= _value
            && balances[_from] >= _value
            && _value > 0                   //make sure that value is greater than zero
            );
            balances[_from] = balances[_from].sub(_value);      //sending address and value
            balances[_to] = balances[_to].add(_value);        //recipient address and value
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);       //subtract the sent tokens from the total _value
            Transfer(_from, _to, _value);
            return true;
    }
    
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value); //log that we have given an approval to track 
        return true;
    }
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender]; 
    }
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    

}