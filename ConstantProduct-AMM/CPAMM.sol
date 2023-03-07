// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./IERC20.sol";

contract CPAMM {
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;
    uint256 public reserve0;
    uint256 public reserve1;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function _mint(address _to, uint256 _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint256 _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function _update(uint256 _reserve0, uint256 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function swap(
        address _tokenIn,
        uint256 _amountIn
    ) external returns (uint256 amountOut) {
        require(
            _tokenIn == address(tokenA) || _tokenIn == address(tokenA),
            "not any token you"
        );
        require(_amountIn > 0, "amount in qualk to 0");
        bool isTokenA = _tokenIn == address(tokenA);
        (
            IERC20 tokenIn,
            IERC20 tokenOut,
            uint256 reserveIn,
            uint256 reserveOut
        ) = isTokenA
                ? (tokenA, tokenB, reserve0, reserve1)
                : (tokenB, tokenA, reserve1, reserve0);
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);
        uint256 amountInWithFee = (_amountIn * 997) / 1000;

        amountOut =
            (reserveOut * amountInWithFee) /
            (reserveIn + amountInWithFee);
        tokenOut.transfer(msg.sender, amountOut);
        _update(
            tokenA.balanceOf(address(this)),
            tokenB.balanceOf(address(this))
        );
    }

    function _sqrt(uint256 y) private pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function addLiquidity(
        uint256 _amount0,
        uint256 _amount1
    ) external returns (uint256 shares) {
        tokenA.transferFrom(msg.sender, address(this), _amount0);
        tokenB.transferFrom(msg.sender, address(this), _amount1);
        if (reserve0 > 0 || reserve1 > 0) {
            require(reserve0 * _amount1 == reserve1 * _amount0, "dy/ dx !=y/x");
        }
        if (totalSupply == 0) {
            shares = _sqrt(_amount0 * _amount1);
        } else {
            shares = _min(
                (_amount0 * totalSupply) / reserve0,
                (_amount1 * totalSupply) / reserve1
            );
        }
        require(shares > 0, "shares==0");
        _mint(msg.sender, shares);
        _update(
            tokenA.balanceOf(address(this)),
            tokenB.balanceOf(address(this))
        );
    }

    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }

    function removeLiquidity(
        uint _shares
    ) external returns (uint amount0, uint amount1) {
        uint bal0 = tokenA.balanceOf(address(this));
        uint bal1 = tokenB.balanceOf(address(this));
        amount0 = (_shares * bal0) / totalSupply;
        amount1 = (_shares * bal1) / totalSupply;
        require(amount0 > 0 && amount1 > 0, "amount0 or amount1 ==0");
        _burn(msg.sender, _shares);
        _update(bal0 - amount0, bal1 - amount1);
        tokenA.transfer(msg.sender, amount0);
        tokenB.transfer(msg.sender, amount1);
    }
}
