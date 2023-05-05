# Nonphysical.systems Contracts

Foundry project

## Testing

```
// Verbose enough for console.log to output the set of interfaceIds used
//  for each capability on the frontend
$ forge test -vv
```

## Deployment

```
$ cp .env.example .env
$ nano .env
$ source .env
$ forge script script/PostV1.s.sol:Deploy --rpc-url $MUMBAI_RPC_URL --broadcast --verify -vvvv
```
