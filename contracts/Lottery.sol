// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/**
 * @title Lottery
 * 一个简单的彩票竞猜智能合约。
 * 该合约会实现一个简单彩票游戏，玩家可以在其中为自己购买彩票，或将其赠送给另一位用户。
 * 当1小时过去了，或有10名参与者，下一个参加抽奖的玩家将执行一个选择获胜者的函数。
 * 存储在合约钱包中的所有资金都将发送给获胜者，之后游戏会开始新的一轮。
*/


contract Lottery {

  // 投注人地址集合
  address payable[] public players;
  // 每次投注的额定金额
  uint public lotteryBet;
  // 每轮投注的起始时间点
  uint public startTime;
  // 每次可以开奖的结束时间点
  uint public endTime;

  constructor() {
    players = new address payable[](0);
    // 每次投注的额定金额，设定0.1个ehter
    lotteryBet = 0.1 ether;
    startTime = block.timestamp;
    // 一小时后可以开奖
    endTime = block.timestamp + 60 minutes;
  }

  // 投注
  function bet() public payable{
    // 检查投注人数，如果达到10人，或者已经超过1小时，则开奖；
    if ((players.length >= 10) || (block.timestamp >= endTime)) {
      // 开奖
      draw();
      // 开奖后，启动新一轮的投注
      newRound();
    } else {
      // 投注
      // 保证投注的金额为额定金额
      require(msg.value == lotteryBet, "Must send 0.1 ether amount");
      // 将该彩民的地址添加进数组
      players.push(payable(msg.sender));
    }
  }

  // 开奖
  function draw() internal {
    // 确保有人投注
    require(players.length != 0, "No players");

    // 利用当前区块的时间戳、挖矿难度和盘内投注彩民数来取随机值
    bytes memory randomInfo = abi.encodePacked(block.timestamp, block.difficulty, players.length);
    bytes32 randomHash =keccak256(randomInfo);

    // 随机抽奖
    address payable winner;
    winner = players[uint(randomHash)%players.length];

    // 将奖金池中的所有金额转账给中奖人
    winner.transfer(getBalance());

  }

  // 开始新一轮的投注
  function newRound() internal {
    // 清空投注人数组
    delete players;
    // 新一轮的起始时间
    startTime = block.timestamp;
    // 一个小时后可以开奖
    endTime = block.timestamp + 60 minutes;
  }

	//返回当前奖池中以太坊的总额
	function getBalance() public view returns(uint){
        return address(this).balance;
  }

}
