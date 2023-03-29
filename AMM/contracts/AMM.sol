// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract CPAMM {
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;
    uint256 public reserveA;
    uint256 public reserveB;
    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function _mint(address _to, uint256 _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _to, uint256 _amount) private {
        balanceOf[_to] -= _amount;
        totalSupply -= _amount;
    }

    function _update(uint _reserveA, uint _reserveB) private {
        reserveA = _reserveA;
        reserveB = _reserveB;
    }

    function swap(
        address _tokenIn,
        uint _amountIn
    ) external returns (uint amountOut) {
        require(
            _tokenIn == address(tokenA) || _tokenIn == address(tokenB),
            "invalid token"
        );
        require(_amountIn > 0, "amount in is =0");
        bool isTokenA = _tokenIn == address(tokenA);
        (
            IERC20 tokenIn,
            IERC20 tokenOut,
            uint reserveIn,
            uint reserveOut
        ) = isTokenA
                ? (tokenA, tokenB, reserveA, reserveB)
                : (tokenB, tokenA, reserveB, reserveA);

        tokenIn.transferFrom(msg.sender, address(this), _amountIn);

        uint amountWithFee = (_amountIn * 997) / 1000;
        amountOut = (reserveOut * amountWithFee) / (reserveIn + amountWithFee);
        tokenOut.transfer(msg.sender, amountOut);
        _update(
            tokenA.balanceOf(address(this)),
            tokenA.balanceOf(address(this))
        );
    }


function addLiquidity(uint _amount0,uint amount1) external returns(uint shares)
{
    tokenA.transferFrom(msg.sender,address(this)._amount0);
    tokenB.transferFrom(msg.sender,address(this),_amount1);
    if(reserveA>0 || reserveB>0)
    {
        require(reserveA*_amount1==reserveB*_amount0,"not equal");
    if(totalSuppply==0)
    {
        shares= _sqrt(_amount0*_amount1);
    }
    else {
            shares = _min(
                (_amount0 * totalSupply) / reserveA,
                (_amount1 * totalSupply) / reserveB
            );
        }
        require(shares > 0, "shares = 0");
        _mint(msg.sender, shares);

        _update(tokenA.balanceOf(address(this)), tokenB.balanceOf(address(this)));
}
   
}
    function _sqrt(uint y) private pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }

}
