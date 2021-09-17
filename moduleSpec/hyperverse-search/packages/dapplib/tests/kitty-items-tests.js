const assert = require('chai').assert;
const DappLib = require('../src/dapp-lib.js');
const fkill = require('fkill');

describe('Flow Dapp Tests', async () => {

    let config = null;
    before('setup contract', async () => {
        // Setup tasks for tests
        config = DappLib.getConfig();
    });

    after(() => {
        fkill(':3570');
    });

    describe('Kitty Items', async () => {
        it(`sets up two accounts`, async () => {
            let testData1 = {
                signer: config.accounts[0]
            }
            let testData2 = {
                signer: config.accounts[1]
            }

            await DappLib.kibbleSetupAccount(testData1);
            await DappLib.kibbleSetupAccount(testData2);

            await DappLib.kittyItemsSetupAccount(testData1);
            await DappLib.kittyItemsSetupAccount(testData2);

            await DappLib.kittyItemsMarketSetupAccount(testData1);
            await DappLib.kittyItemsMarketSetupAccount(testData2);
        });

        it(`mints kibble into the admin account and has the correct balance in the account`, async () => {
            let testData1 = {
                amount: "30.0",
                recipient: config.accounts[0]
            }
            let testData2 = {
                address: config.accounts[0]
            }

            await DappLib.kibbleMintTokens(testData1)

            let res1 = await DappLib.kibbleGetBalance(testData2)
            let res2 = await DappLib.kibbleGetSupply({})

            assert.equal(res1.result, 30.0, "Admin has incorrect balance")

            assert.equal(res2.result, 30.0, "Incorrect total number of Kibble")
        })

        it(`cannot mint 0 kibble and doesn't affect supply`, async () => {
            let testData1 = {
                amount: "0.0",
                recipient: config.accounts[0]
            }

            try {
                await DappLib.kibbleMintTokens(testData1)
            } catch (e) {
                let res = await DappLib.kibbleGetSupply({})
                assert.equal(res.result, 30.0, "Incorrect total number of Kibble")
            }
        })

        it(`cannot withdraw more than vault has but balances and supply remain the same`, async () => {
            let testData1 = {
                signer: config.accounts[0],
                amount: "100.0",
                to: config.accounts[1]
            }
            let testData2 = {
                address: config.accounts[0]
            }
            let testData3 = {
                address: config.accounts[1]
            }

            try {
                await DappLib.kibbleTransferTokens(testData1)
            } catch (e) {
                let res1 = await DappLib.kibbleGetBalance(testData2)
                let res2 = await DappLib.kibbleGetBalance(testData3)

                let res3 = await DappLib.kibbleGetSupply({})

                assert.equal(res1.result, 30.0, "Admin has incorrect balance")
                assert.equal(res2.result, 0.0, "User has incorrect balance")

                assert.equal(res3.result, 30.0, "Incorrect total number of Kibble")
            }
        })

        it(`transfers kibble from admin to user`, async () => {
            let testData1 = {
                signer: config.accounts[0],
                amount: "10.0",
                to: config.accounts[1]
            }
            let testData2 = {
                address: config.accounts[0]
            }
            let testData3 = {
                address: config.accounts[1]
            }

            await DappLib.kibbleTransferTokens(testData1)

            let res1 = await DappLib.kibbleGetBalance(testData2)
            let res2 = await DappLib.kibbleGetBalance(testData3)

            let res3 = await DappLib.kibbleGetSupply({})

            assert.equal(res1.result, 20.0, "Admin has incorrect balance")
            assert.equal(res2.result, 10.0, "User has incorrect balance")

            assert.equal(res3.result, 30.0, "Incorrect total number of Kibble")
        })

        it(`has 0 initial kittyitems in the supply`, async () => {
            let res = await DappLib.kittyItemsReadKittyItemsSupply({})

            assert.equal(res.result, 0, "There should be 0 initial KittyItems")
        })

        it(`mints 2 kittyitems into admin account and has correct collection information`, async () => {
            let testData1 = {
                recipient: config.accounts[0],
                typeID: "5"
            }
            let testData2 = {
                address: config.accounts[0]
            }

            await DappLib.kittyItemsMintKittyItem(testData1)
            await DappLib.kittyItemsMintKittyItem(testData1)

            let res1 = await DappLib.kittyItemsReadCollectionIDs(testData2)
            let res2 = await DappLib.kittyItemsReadCollectionLength(testData2)

            assert.equal(res1.result[0], 0, "Incorrect ID in KittyItems collection")
            assert.equal(res1.result[1], 1, "Incorrect ID in KittyItems collection")
            assert.equal(res2.result, 2, "Incorrect length of KittyItems collection")
        })

        it(`has correct total number of kittyitems and kittyitem typeID is correct`, async () => {
            let testData = {
                address: config.accounts[0],
                itemID: "0"
            }

            let res1 = await DappLib.kittyItemsReadKittyItemsSupply({})

            let res2 = await DappLib.kittyItemsReadKittyItemTypeID(testData)

            assert.equal(res1.result, 2, "Incorrect total number of KittyItems")

            assert.equal(res2.result, 5, "KittyItem has incorrect typeID")
        })

        it(`safely fails when withdrawing kittyitem with wrong id`, async () => {
            let testData1 = {
                signer: config.accounts[0],
                recipient: config.accounts[1],
                withdrawID: "10"
            }

            let testData2 = {
                address: config.accounts[0]
            }
            let testData3 = {
                address: config.accounts[1]
            }

            try {
                await DappLib.kittyItemsTransferKittyItem(testData1)
            } catch (e) {
                let res1 = await DappLib.kittyItemsReadCollectionLength(testData2)
                let res2 = await DappLib.kittyItemsReadCollectionLength(testData3)

                assert.equal(res1.result, 2, "Admin should have 2 KittyItems after fail")
                assert.equal(res2.result, 0, "User should have 0 KittyItems after fail")
            }
        })

        it(`transfers 2 kittyitems from admin to user and has correct collection information`, async () => {
            let testData1 = {
                signer: config.accounts[0],
                recipient: config.accounts[1],
                withdrawID: "0"
            }
            let testData2 = {
                signer: config.accounts[0],
                recipient: config.accounts[1],
                withdrawID: "1"
            }
            let testData3 = {
                address: config.accounts[0]
            }
            let testData4 = {
                address: config.accounts[1]
            }

            await DappLib.kittyItemsTransferKittyItem(testData1)
            await DappLib.kittyItemsTransferKittyItem(testData2)

            let res1 = await DappLib.kittyItemsReadCollectionLength(testData3)
            let res2 = await DappLib.kittyItemsReadCollectionLength(testData4)
            let res3 = await DappLib.kittyItemsReadCollectionIDs(testData4)

            assert.equal(res1.result, 0, "Admin should have no KittyItems left")
            assert.equal(res2.result, 2, "User should have a KittyItem")
            assert.equal(res3.result[0], 0, "User should have a KittyItem")
            assert.equal(res3.result[1], 1, "User should have a KittyItem")
        })

        it(`lists 2 kittyitems for sale`, async () => {
            let testData1 = {
                signer: config.accounts[1],
                itemID: "0",
                price: "15.0"
            }
            let testData2 = {
                signer: config.accounts[1],
                itemID: "1",
                price: "15.0"
            }
            let testData3 = {
                address: config.accounts[1]
            }
            let testData4 = {
                marketCollectionAddress: config.accounts[1]
            }

            await DappLib.kittyItemsMarketSellMarketItem(testData1)
            await DappLib.kittyItemsMarketSellMarketItem(testData2)

            let res1 = await DappLib.kittyItemsMarketReadCollectionIDs(testData3)
            let res2 = await DappLib.kittyItemsMarketReadCollectionLength(testData4)

            assert.equal(res1.result[0], 0, "User's Market collection should have a KittyItem with itemID 0")
            assert.equal(res1.result[1], 1, "User's Market collection should have a KittyItem with itemID 1")
            assert.equal(res2.result, 2, "User should have 2 KittyItems up for sale")
        })

        it(`removes a kittyitem from sale`, async () => {
            let testData1 = {
                signer: config.accounts[1],
                itemID: "0"
            }
            let testData2 = {
                marketCollectionAddress: config.accounts[1]
            }
            let testData3 = {
                address: config.accounts[1]
            }

            await DappLib.kittyItemsMarketRemoveMarketItem(testData1)

            let res1 = await DappLib.kittyItemsMarketReadCollectionLength(testData2)
            let res2 = await DappLib.kittyItemsMarketReadCollectionIDs(testData3)

            assert.equal(res1.result, 1, "User should have 1 KittyItem up for sale after delisting one")
            assert.equal(res2.result[0], 1, "User should still have a KittyItem with itemID 1 up for sale")
        })

        it(`buys a kittyitem and has correct market collection information`, async () => {
            let testData1 = {
                signer: config.accounts[0],
                itemID: "1",
                marketCollectionAddress: config.accounts[1]
            }
            let testData2 = {
                marketCollectionAddress: config.accounts[1]
            }

            await DappLib.kittyItemsMarketBuyMarketItem(testData1)

            let res1 = await DappLib.kittyItemsMarketReadCollectionLength(testData2)

            assert.equal(res1.result, 0, "User should have 0 KittyItems up for sale after Admin bought one")
        })

        it(`checks admin actually has a kittyitem in collection`, async () => {
            let testData = {
                address: config.accounts[0]
            }

            let res1 = await DappLib.kittyItemsReadCollectionIDs(testData)
            let res2 = await DappLib.kittyItemsReadCollectionLength(testData)

            assert.equal(res1.result[0], 1, "Incorrect ID in KittyItem collection")
            assert.equal(res2.result, 1, "Incorrect length of KittyItem collection")
        })

        it(`checks both admin and user have correct balances after purchase`, async () => {
            let testData1 = {
                address: config.accounts[0]
            }
            let testData2 = {
                address: config.accounts[1]
            }

            let res1 = await DappLib.kibbleGetBalance(testData1)
            let res2 = await DappLib.kibbleGetBalance(testData2)

            assert.equal(res1.result, 5.0, "Admin has incorrect balance")
            assert.equal(res2.result, 25.0, "User has incorrect balance")
        })
    });

});