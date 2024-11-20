
# Supernormal ZIPS by Zipcy

Here you can see the simple breakdown of all of the contracts related to ZIPS collection by Supernormal.

## IFXRoot.sol

Interface for the FXRoot contract which is used to send messages from Ethereum Mainnet to Polygon. Messages are sent once a transfer happens on an NFT to update its current holder on the on-chain points database on Polygon.

## IMigration.sol

Interface of the new Supernormal contract post-migration. Used by the staking contract which later was turned into a migration contract.

## SuperNormalHarvesterV2.sol

Staking-Migration contract for Supernormal ZIPS collection. It was first created as a hard staking contract but then changed into a migration contract. It has two different functionalities. 
Users can either stake token which sends their old ZIPS directly to a predetermined burn address and when unstaked mints their ZIPS on the new contract; or they can use the migrateTokens function to directly migrate without staking-unstaking process.

## SuperNormalV3.sol

A basic ERC721 contract that uses ERC1967Proxy for future possible upgrades. It has burning, tradelocking tokens and minting new tokens only through Harvester contract as extra additions. 

## Deployment Addresses

SupernormalHarvesterV2.sol: `0xa1A9b59FFe51B69A8Ba305C4813267c69626297d`
SuperNormalV3.sol: `0xb0640E8B5F24beDC63c33d371923D68fDe020303`