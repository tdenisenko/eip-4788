# EIP-4788 proofs verification

Scripts taken from https://github.com/madlabman/eip-4788-proof

Updated for use on mainnet

## Usage

```bash
cd script
yarn install

# Provide an address of a CL API endpoint.
export BEACON_NODE_URL=http://127.0.0.1:5052
yarn test
```

### Foundry Tests

Foundry tests read JSON files fixtures and use the contracts from the repository
to accepts proofs.

```bash
forge test -vvv --fork-url $BEACON_NODE_URL --fork-block-number 21160254
```

