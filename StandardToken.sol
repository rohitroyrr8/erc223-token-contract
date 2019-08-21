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
        returns (string) {
        return _name;
    }

    function symbol()
        public
        view
        returns (string) {
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
    	balances[msg.sender] = balances[msg.sender].sub(_value);
    	balances[_to] = balances[_to].add(_value);

    }
}

