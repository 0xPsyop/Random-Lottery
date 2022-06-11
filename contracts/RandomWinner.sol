//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract Lottery is VRFConsumerBase, Ownable {
   
   //for chainlink
   uint public fee;
   bytes32 public keyHash;

   //for funcs
   uint entryFee;
   uint maxPlayers;
   uint public gameID;

   bool public gameStarted;
   address[] public players;

   event GameStarted(uint gameID, uint maxPlayers, uint entryFee);
   event JoinedGame(uint gameID, address player);
   event GameEnded( uint gameID, address winner , bytes32 requestID );

   constructor(address vrfCoordinator, address linkToken, bytes32 vrfKeyHash, uint256 vrfFee)
    VRFConsumerBase( vrfCoordinator, linkToken) {
           fee = vrfFee;
           keyHash = vrfKeyHash;
           gameStarted = false;
   }
   
   function startGame( uint _maxPlayers, uint _entryFee) public onlyOwner {
       require(!gameStarted, "One game is already running");
       delete players;

       entryFee = _entryFee;
       maxPlayers = _maxPlayers;
       gameID += 1 ;
       gameStarted = true;
       emit GameStarted(gameID, maxPlayers, entryFee);
   }

   function joinGame () public payable{
       require(gameStarted, "No game is active now");
       require(msg.value == entryFee , "Not enough Ether to enter the game");
       require(players.length < maxPlayers, "The current game is full");

       players.push(msg.sender);
       
       if(players.length  == maxPlayers){
          getRandomWinner();
       }
       emit JoinedGame(gameID, msg.sender);

   }
   function fulfillRandomness(bytes32 requestID, uint256 randomness) internal virtual override{
    
     uint256 winnerIndex= randomness % players.length ;
     address winner = players[winnerIndex];

      (bool sent,) = winner.call{value: address(this).balance}("");
      require(sent , "Faied to send the Ether");
      emit GameEnded(gameID, winner , requestID);
      gameStarted = false;
   }

   function getRandomWinner() private returns(bytes32 requestID){
       
       require(LINK.balanceOf(address(this)) >= fee, "Not enough Link lol");
       
       //This is a func in the VRFconsumerbase contract to start the process
       requestRandomness(keyHash, fee);
   }

   receive() external payable {}

   fallback() external payable {} 
}
