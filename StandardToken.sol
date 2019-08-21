pragma solidity ^0.5.0;

import "math/SafeMath.sol";
import "lib/ERC20.sol";
import "lib/ERC223/sol";
import "lib/ERC223ReceivingContract";

contract StandardToken is ERC20, ERC223 {
	using SafeMath for uint;

	string internal _name;
	string internal _symbol;
	uint8 internal _decimals;
	uint256 internal _totalSupply;

	mapping(address => uint256) internal balances;
	mapping(address => mapping(address => uint256)) internal allowed;

	constructor() public {
		_name = "StandardToken";
		_symbol = "STT";
		_decimals = 18;
		_totalSupply = 1000;
		balances[msg.sender] = _totalSupply;
	}

	function name()
        public
        view
        returns (string memory) {
        return _name;
    }

    function symbol()
        public
        view
        returns (string memory) {
        return _symbol;
    }

    function decimals()
        public
        view
        returns (uint8) {
        return _decimals;
    }

    function totalSupply()
        public
        view
        returns (uint256) {
        return _totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
    	require(_to != address(0));
    	require(_value < balances[msg.sender]);
    	balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
    	balances[_to] = SafeMath.add(balances[_to], _value);

    	emit Transfer(msg.sender, _to, _value);
    	return true;

    }

    function balanceOf(address _address) public view returns (uint256) {
    	return balances[_address];
    }

    function transferFrom(address _to, address _from, uint256 _value) public returns (bool) {
    	require(_to != address(0));
     	require(_value <= balances[_from]);
     	require(_value <= allowed[_from][msg.sender]);

     	balances[_from] = SafeMath.sub(balances[_from], _value);
     	balances[_to] = SafeMath.add(balances[_to], _value);
     	allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);

     	emit Transfer(_from, _to, _value);
     	return true;
    }


    function approve(address _spender, uint256 _value) public returns (bool) {
    	allowed[msg.sender][_spender] = _value;
    	emit Approval(msg.sender, _spender, _value);
    	return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
    	return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    	allowed[msg.sender][_spender] = SafeMath.add(allowed[msg.sender][_spender], _addedValue);
    	emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    	return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    	uint oldValue = allowed[msg.sender][_spender];
    	if(_subtractedValue > oldValue) {
    		allowed[msg.sender][_spender] = 0;
    	} else {
    		allowed[msg.sender][_spender] = SafeMath.sub(oldValue, _subtractedValue);
    	}

    	emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    	return true;
    }

    function transfer(address _to, uint _value, bytes memory _data) public {
    	require(_value > 0);
    	if(isContract(_to)) {
    		ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
    		receiver.tokenFallback(msg.sender, _value, _data);
    	}
    	balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value, _data);
    }

    function isContract(address _address) private returns (bool) {
    	
    	uint length;
        assembly {
                //retrieve the size of the code on target address, this needs assembly
                length := extcodesize(_address)
          }
          return (length>0);
    } 
}

