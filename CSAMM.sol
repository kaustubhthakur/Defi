// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IERC20.sol";

contract CSMM {
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;

    uint256 public reserveA;
    uint256 public reserveB;
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
   function _update(uint _res0, uint _res1) private {
        reserveA = _res0;
        reserveB = _res1;
    }
    function swap(address _tokenIn, uint256 _amountIn)
        external returns (uint256 amountOut)
    {
        require(_tokenIn == address(tokenA) || _tokenIn == address(tokenB),"Ivalid token");
 
        bool isToken0 = _tokenIn == address(tokenA);

        (IERC20 tokenIn, IERC20 tokenOut, uint resIn, uint resOut) = isToken0
            ? (tokenA, tokenB, reserveA, reserveB)
            : (tokenB, tokenA, reserveB, reserveA);

        tokenIn.transferFrom(msg.sender, address(this), _amountIn);
        uint amountIn = tokenIn.balanceOf(address(this)) - resIn;

       
        amountOut = (amountIn * 997) / 1000;

        (uint res0, uint res1) = isToken0
            ? (resIn + amountIn, resOut - amountOut)
            : (resOut - amountOut, resIn + amountIn);

        _update(res0, res1);
        tokenOut.transfer(msg.sender, amountOut);

    }


      function addLiquidity(uint _amount0, uint _amount1) external returns (uint shares) {
        tokenA.transferFrom(msg.sender, address(this), _amount0);
        tokenB.transferFrom(msg.sender, address(this), _amount1);

        uint bal0 = tokenA.balanceOf(address(this));
        uint bal1 = tokenB.balanceOf(address(this));

        uint d0 = bal0 - reserveA;
        uint d1 = bal1 - reserveB;

       
        if (totalSupply > 0) {
            shares = ((d0 + d1) * totalSupply) / (reserveA + reserveB);
        } else {
            shares = d0 + d1;
        }

        require(shares > 0, "shares = 0");
        _mint(msg.sender, shares);

        _update(bal0, bal1);
    }

    function removeLiquidity(uint _shares) external returns (uint d0, uint d1) {
      
        d0 = (reserveA * _shares) / totalSupply;
        d1 = (reserveB * _shares) / totalSupply;

        _burn(msg.sender, _shares);
        _update(reserveA- d0, reserveB - d1);

        if (d0 > 0) {
            tokenA.transfer(msg.sender, d0);
        }
        if (d1 > 0) {
            tokenB.transfer(msg.sender, d1);
        
    }
}


}
