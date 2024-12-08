// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CharityRegistry.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract GivingThanks is ERC721URIStorage {
    CharityRegistry public registry;
    uint256 public tokenCounter;
    address public owner;

    constructor(address _registry) ERC721("DonationReceipt", "DRC") {
        registry = CharityRegistry(_registry);
        owner = msg.sender;
        tokenCounter = 0;
    }

    function donate(address charity) public payable {
        require(registry.isVerified(charity), "Charity not verified");
        /* gSEC
        
        There are several ways to send Ether to the `charity` address in Solidity. Here are three common methods:

        1. **Using `transfer`**:
        ```solidity
        charity.transfer(msg.value);
        ```

        2. **Using `send`**:
        ```solidity
        bool sent = charity.send(msg.value);
        require(sent, "Failed to send Ether");
        ```

        3. **Using `call`** (already used in your code):
        ```solidity
        (bool sent,) = charity.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        ```

        ### Comparison:
        - **`transfer`**: Automatically reverts on failure, forwards 2300 gas, and is considered safe for simple transfers.
        - **`send`**: Returns a boolean indicating success or failure, forwards 2300 gas, and requires manual error handling.
        - **`call`**: More flexible, forwards all available gas by default, and can be used for calling functions on the target contract. It requires careful handling to avoid reentrancy attacks.

        In your case, using `call` is appropriate if you need to forward all available gas or interact with a contract. If you only need to send Ether without interacting with a contract, `transfer` or `send` might be simpler and safer.
        */
        (bool sent,) = charity.call{value: msg.value}("");
        require(sent, "Failed to send Ether");

        _mint(msg.sender, tokenCounter);

        // Create metadata for the tokenURI
        string memory uri = _createTokenURI(msg.sender, block.timestamp, msg.value);
        _setTokenURI(tokenCounter, uri);

        tokenCounter += 1;
    }

    function _createTokenURI(address donor, uint256 date, uint256 amount) internal pure returns (string memory) {
        // Create JSON metadata
        string memory json = string(
            abi.encodePacked(
                '{"donor":"',
                Strings.toHexString(uint160(donor), 20),
                '","date":"',
                Strings.toString(date),
                '","amount":"',
                Strings.toString(amount),
                '"}'
            )
        );

        // Encode in base64 using OpenZeppelin's Base64 library
        string memory base64Json = Base64.encode(bytes(json));

        // Return the data URL
        return string(abi.encodePacked("data:application/json;base64,", base64Json));
    }

    function updateRegistry(address _registry) public {
        registry = CharityRegistry(_registry);
    }
}
