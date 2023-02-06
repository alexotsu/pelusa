pragma solidity >= 0.8.7;

contract Game {
    address public getBallPossesion;
    function updateOwner(address newOwner) public {
        getBallPossesion = newOwner;
    }
}