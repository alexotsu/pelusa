# [Pelusa](https://quillctf.super.site/challenges/quillctf-challenges/pelusa)

## Requirements Gathering

Given the objective of **Score from 1 to 2 goals for a win.**, we first review the code.

The variable `goals` starts out being set to `1`, but there is no function that references it in the contract. However, we see there is a `delegatecall` operation being done in the `shoot()` contract, and since we know `delegatecall` can change the calling contract's state using the target contract's logic, it suggests that the the call to `handOfGod()` at the **player** address needs to be responsible for changing the state.

Because we know that the `shoot()` function needs to be called, we can start considering the requirements for calling it successfully.

1. `isGoal()` must return `true`.
    This reveals two sub-requirements:
        a. The **player** contract must have a function called `getBallPossesssion()`, which returns the `owner` value.
        b. Becauses the `owner` value is pre-computed when the **Pelusa** contract was deployed, we know we have to compute it independently to make the **player** contract return the correct value.
2. `player.delegatecall(abi.encodeWithSignature("handOfGod()"))` must be a successful call and its return data must be `22061986`. Lastly, it must contain logic to change the value in its second storage slot to `2`.
    Note: it needs to change the value in the second storage slot because the first variable in **Pelusa** is marked as `immutable`, so it gets stored directly in the bytecode instead of in storage.
3. In order to make the above calls, **player** needed to be set. The only way to do so is by making a successful call to `passTheBall()`, but it requires the code length of the caller to be 0 or else will revert. Fortunately, we know that when a contract's constructor calls a function, it still registers as a codesize of `0`.
    Next, the address of `msg.sender`, when divided by 100, needs to have a remainder of 10. So there needs to be some way of predicting where the contract address will be that will call `passTheBall()` in its constructor.

## Setting up the Contract
The first step was writing the code that would live at the **player** address. That is below:

```
contract Exploiter {
    address immutable Pelusa;
    address internal player;
    uint public goals;
    address game;

    constructor() {
        Pelusa = 0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95; // pre-computed address. In practice, we would know where the Pelusa contract was deployed beforehand so would replace this value with the Pelusa address.
        // saves us the need to import a Pelusa interface
        address(0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95).call(abi.encodeWithSignature("passTheBall()"));
    }

    function updateGameAddress(address addr) public {
        game = addr;
    }
    
    function getBallPossesion() public view returns(address owner) {
        owner = Game(game).getBallPossesion();
    }

    function handOfGod() public returns(uint256 val) {
        goals = 2;
        val = 22061986;
    }
}
```
The `Exploiter` code has an identical storage layout as **Pelusa** up to the `goals` variable (I even named them the same thing, although that wasn't necessary). It also has another variable to store the address for the **Game** contract, so that I wouldn't also have to pass the `owner` address in as a dynamic constructor value (because I didn't know how to do that at the time).

It calls `passTheBall()` in its constructor, and the rest of the functions set it up to return the correct values when called by **Pelusa**.

## Calculating the Deployment Address

With the contract compiled into bytecode, we have code that fulfills the first two requirements. Next, it was time to figure out how to deploy the contract to an address that would allow it to pass the second check in `passTheBall()`.

**Note**: copy the `bytecode` from the **Exploiter.json** file, **not** the `deployedBytecode`. Using the latter will cause errors. Read more about how bytecode is used to deploy more bytecode [here](https://medium.com/@kalexotsu/writing-evm-logic-in-opcodes-deploying-opcode-logic-on-chain-205618fee38d).

This looks like a job for the [Assembly instruction `create2`](https://docs.soliditylang.org/en/v0.8.18/yul.html), which deploys a contract at a deterministic address given its bytecode and a salt.

The rest of this step occurs off-chain. I wrote a script that uses [Foundry's `cast create2`](https://book.getfoundry.sh/reference/cast/cast-create2?highlight=create2#cast-create2) command to cycle through addresses until it found a salt value that met the criteria.

The `create2` instruction needs to be called from a contract, so I set one up called **ExploiterDeployer** that takes the bytecode and the salt as arguments and deploys `Exploiter`.

## Testing

Putting it all together, the test file sets up the **Pelusa**, **ExploiterDeployer**, and **Game** contract, deploys `Exploiter` through **ExploiterDeployer**, and calls `shoot()`. The `goals()` variable returns `true` after doing so.