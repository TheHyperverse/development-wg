Here you will find two contracts: HyperverseInterface.cdc and HyperverseService.cdc

The HyperverseInterface is the contract interface that ALL composable contracts have to implement. You'll see it requires a ContractMetadata struct defined in the HyperverseService, which is what users register to in order to receive Tenants.

We can think about what should be added/removed from this ContractMetadata. This will serve as on-chain metadata so that our front-end can query it for discoverability and more. Note it also includes fixedFees and dynamicFees, this isn't important for now and will be more important later when we explore monetization. The idea, though, is that the fees for paid functions would be stored here.