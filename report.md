# Exploits

## Donation to Unverified Charity

### Invariant

Donors should only donate to verified charities.

### Exploit

 `GivingThanks.sol` has a `donate` function that requires a charity to be verified before accepting donations. However, the `isVerified` function in `CharityRegistry.sol` checks if the charity is registered as opposed to verified. This allows a donor to donate to an unverified charity.

 The `testDonateToUnverifiedCharity` function in `GivingThanksHacks.t.sol` demonstrates this exploit.

### Fix

Change the `isVerified` function in `CharityRegistry.sol` to check if the charity is verified.

```solidity
function isVerified(address charity) public view returns (bool) {
    return verifiedCharities[charity];
}
```

## Donations can be halted

### Invariant

Donations should not be able to be halted.

### Exploit

`GivingThanks.sol` has a public function called `updateRegistry` that allows anyone to update the charity registry to a new address. The `setUp` function in `GivingThanksStopDonations.t.sol` registers and verifies a charity, per a normal work flow. However, the function `testStopDonations` demonstrates that the charity registry can be updated to a new address by any user. In this case, the charity registry is updated to an address that does not have any charities registered, effectively halting donations to previously registered and verified charities.

### Fix

Require that only the owner of the contract can update the charity registry.

```solidity
function updateRegistry(address newRegistry) public {
    require(msg.sender == owner, "Only the owner can update the registry");
    charityRegistry = CharityRegistry(newRegistry);
}
```
