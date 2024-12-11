# Exploits

## Donation to Unverified Charity

### Invariant

Donors should only donate to verified charities.

### Exploit

 `GivingThanks.sol` has a `donate` function that requires a charity to be verified before accepting donations. 
However, the `isVerified` function in `CharityRegistry.sol` checks if the charity is registered as opposed to verified. This allows a donor to donate to an unverified charity.

 `GivingThanksHacks.t.sol`