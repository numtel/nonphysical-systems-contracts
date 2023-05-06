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
# Deploy a PostV1Factory and an example first post to mumbai testnet
$ npm run deploy:PostV1
# Deploy a PostBrowser with all available fetchers/replyFetchers to mumbai testnet
$ npm run deploy:PostBrowser
```
