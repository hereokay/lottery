// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "VRF.sol";


contract Lottery {

    mapping (uint256 => mapping (address => uint256[2])) table; // 0 : 번호, 양
    mapping (uint256 => uint256) win_number;
    uint256 round = 1;

    address VRFD_addr = 0x61d82D68595e24F235c20937362DD02D7736F687;
    VRFD20 callee = VRFD20(VRFD_addr);

    address token_addr = 0x4f021F693EDb252401E67eCC6D07c9bcd5310767;
    ERC20 token = ERC20(token_addr);

    function lottary_in(uint256 number) public payable {
        require(msg.value >= 1,"to pay more than 1 wei");
        table[round][msg.sender][0] = number;
        table[round][msg.sender][1] = msg.value;
    }
    
    function random_call() public {
        callee.rollDice();
    }

    function lottart_set() public {
        win_number[round] = callee.getRandomNumber();
        round = round + 1;
    }

    function lottart_set_without_round_up() public {
        win_number[round] = callee.getRandomNumber();
    }

    function claim(uint target_round, uint number) public {
        require(table[target_round][msg.sender][0] == number);
        require(win_number[target_round]==number);

        uint256 reward = table[target_round][msg.sender][1] * 3;
        token.transfer(msg.sender,reward);
    }

    function token2eth(uint256 amount) public {
        require(token.balanceOf(msg.sender) >= amount);

        // 실제 토큰 전송
        token.transferFrom(msg.sender,address(this),amount);

        // ether를 1대1 만큼 전송해준다.
        address payable to = payable(msg.sender); 
        to.transfer(amount); 
    }

    function now_round() view public returns(uint256){
        return round;
    }
    
    function get_win_number(uint256 target_round) view public returns(uint256){
        return win_number[target_round];
    }

    function my_number_and_value(uint target_round) view public returns(uint256[2] memory){
        return table[target_round][msg.sender];
    }


}