/*Implements EIP20 token standard*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IERC20} from "./IERC20.sol";

contract ERC20 is IERC20 {
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    string public name;
    string public symbol;
    uint8 public immutable decimals;
    uint256 public totalSupply;
    address public owner;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    constructor(
        address _owner,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = _owner;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        return _transfer(msg.sender, to, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {
        require(
            allowance[from][msg.sender] >= value,
            "ERC20: Insufficient allowance"
        );

        allowance[from][msg.sender] -= value;

        emit Approval(from, msg.sender, allowance[from][msg.sender]);
        return _transfer(from, to, value);
    }

        }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) private returns (bool) {
        require(balanceOf[from] >= value, "ERC20: Insufficient sender balance");

        emit Transfer(from, to, value);

        balanceOf[from] -= value;

        balanceOf[to] += value;

        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        emit Approval(msg.sender, spender, value);

        allowance[msg.sender][spender] += value;
    }

    function _mint(address to, uint256 value) private {
        balanceOf[to] += value;
        totalSupply += value;
        emit Transfer(address(0), to, value);
    }

    function mint(address to, uint256 value) external onlyOwner {
        _mint(to, value);
    }

    function _burn(address from, uint256 value) private {
        balanceOf[from] -= value;
        totalSupply -= value;
        emit Transfer(from, address(0), value);
    }

    function burn(address from, uint256 value) external onlyOwner {
        _burn(from, value);
    }

    function depositTo(address to) external payable {
        balanceOf[to] += msg.value;
        emit Transfer(address(0), to, msg.value);
    }

    function redeem(uint256 value) external {
        _transfer(msg.sender, msg.sender, value);

        _burn(msg.sender, value);

        emit Transfer(msg.sender, address(0), value);

        (bool success, ) = msg.sender.call{value: value}("");
        require(success, "ERC20: ETH transfer failed");
    }
}
