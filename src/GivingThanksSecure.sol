// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CharityRegistry.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract GivingThanksSecure is ERC721URIStorage {
    CharityRegistry public registry;
    uint256 public tokenCounter;
    address public owner;

    constructor(address _registry) ERC721("DonationReceipt", "DRC") {
        registry = CharityRegistry(_registry);
        owner = msg.sender;
        tokenCounter = 0;
    }

    // DELETE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // WHEN DONE STUDYING CHECKS-EFFECTS-INTERACTIONS
    // function withdraw(uint amount) public {
    //     // checks
    //     require(balances[msg.sender] >= amount);

    //     // effects
    //     balances[msg.sender] -= amount;

    //     // interactions
    //     msg.sender.transfer(amount);
    // }

    function donate(address charity) public payable {
        // Checks
        // check if this new require statement prevents reentrancy
        require(msg.sender != charity, "Donor cannot be the charity");
        require(registry.isVerified(charity), "Charity not verified");

        // Effects
        _mint(msg.sender, tokenCounter);

        // Create metadata for the tokenURI
        string memory uri = _createTokenURI(
            msg.sender,
            block.timestamp,
            msg.value
        );
        _setTokenURI(tokenCounter, uri);

        tokenCounter += 1;

        // Interactions
        (bool sent, ) = charity.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    function _createTokenURI(
        address donor,
        uint256 date,
        uint256 amount
    ) internal pure returns (string memory) {
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
        return
            string(
                abi.encodePacked("data:application/json;base64,", base64Json)
            );
    }

    function updateRegistry(address _registry) public {
        registry = CharityRegistry(_registry);
    }
}
