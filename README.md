# GivingThanks Report

I discovered two high level exploits in the [Cyfrin GivingThanks contest](https://codehawks.cyfrin.io/c/2024-11-giving-thanks). I did not participate in the contest while it was active. I did not look at [the results](https://codehawks.cyfrin.io/c/2024-11-giving-thanks/results?t=report&page=1) of the contest prior to studying the code base for exploits. I discoved two high level exploits that match the two high level exploits in the results.  

I cloned [the original repository](https://github.com/Cyfrin/2024-11-giving-thanks), updated the remotes, and renamed the [original README](original_README.md). I then created this README which includes a report of my findings.  

## Exploits I discovered

### Donation to Unverified Charity

#### Invariant

Donors should only donate to verified charities.

#### Proof of Concept

 `GivingThanks.sol` has a `donate` function that requires a charity to be verified before accepting donations. However, the `isVerified` function in `CharityRegistry.sol` checks if the charity is registered as opposed to verified. This allows a donor to donate to an unverified charity.

 The `testDonateToUnverifiedCharity` function in `GivingThanksHacks.t.sol` demonstrates this exploit.

#### Fix

Change the `isVerified` function in `CharityRegistry.sol` to check if the charity is verified.

```solidity
function isVerified(address charity) public view returns (bool) {
    return verifiedCharities[charity];
}
```

---

### Donations can be halted

#### Invariant

Donations should not be able to be halted.

#### Proof of Concept

`GivingThanks.sol` has a public function called `updateRegistry` that allows anyone to update the charity registry to a new address. The `setUp` function in `GivingThanksStopDonations.t.sol` registers and verifies a charity, per a normal work flow. However, the function `testStopDonations` demonstrates that the charity registry can be updated to a new address by any user. In this case, the charity registry is updated to an address that does not have any charities registered, effectively halting donations to previously registered and verified charities.

#### Fix

Require that only the owner of the contract can update the charity registry.

```solidity
function updateRegistry(address newRegistry) public {
    require(msg.sender == owner, "Only the owner can update the registry");
    charityRegistry = CharityRegistry(newRegistry);
}
```

## Vulnerabilities I Missed

### M-02. Reentrancy in NFT Minting allows Multiple NFTs for Single Donation in GivingThanks.sol

I failed to discover the reentrancy vulnerability in [GivingThanks.donate(...)](https://github.com/Cyfrin/2024-11-giving-thanks/blob/304812abfc16df934249ecd4cd8dea38568a625d/src/GivingThanks.sol#L21). To gain an understanding of reentrancy attacks, I studied the showcased submission by [@nomadic_bear](https://profiles.cyfrin.io/u/nomadic_bear) and then wrote the attack from stratch. My interpretation of the attack is [here]().