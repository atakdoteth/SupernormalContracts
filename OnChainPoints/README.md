
# On-Chain Points Database

The database is for tracking SN points for SUPERNORMAL ecosystem users. It tracks how many days have passed to calculate points for each ZIPS token. Database is on Polygon Mainnet while the ZIPS collection is on Ethereum Mainnet. The messaging between chains is done by using State Tunneling technology from Polygon.

## IFXRoot.sol

Interface of FXRoot contract which is used for sending the data from Ethereum Mainnet.

## ISN.sol

Interface for the SNPoints database.

## FXRoot.sol

Contract used for sending the message to FXChild contract on Polygon.

## FXChild.sol

Recieves the data from StateSync on Polygon. Validates the sender is the FXRoot contract that we deployed so other users/contracts can't change holder status of tokens.

## SNPoints.sol

The recieved data is passed to SNPoints contract on Polygon which decrypts the data and updates holders of each ZIPS token. Since not all ZIPS tokens are migrated and some are still hard-staked the owners of tokens were set initially and holders change dynamically after each transaction from thereon.

## Deployment Addresses

### Ethereum Mainnet
FXRoot.sol: `0x56fF82d400e23f4cE0e7dCE1fAd8981D692d0880`

### Polygon
FXChild.sol: `0x90cc182527a2ca8f337a32959e9efd8ed57bd81a`
SNPoints.sol: `0x04095c45ee4046cf17e2ccac2deadcdd964b8755`


