import FlowToken from Flow.FlowToken
import FungibleToken from Flow.FungibleToken

pub contract HyperverseService {

    // Named Paths
    //
    pub let AuthStoragePath: StoragePath

    // ContractMetadata
    // Any contract that implements HyperverseInterface or 
    // supports Multitenancy using the Tenant architecture must
    // have a ContractMetadata struct. This can be seen in more
    // detail inside HyperverseInterface.
    //
    // Each contract must supply these so HyperverseService can
    // determine fees on its own.
    //
    pub struct ContractMetadata {
        // The name of the contract.
        pub var name: String

        // A title for the contract.
        pub var title: String

        // A description for the contract.
        pub var description: String

        // The contract's version number.
        pub var version: String

        // Maps a function name to a FixedFeeStruct
        pub var fixedFees: {String: FixedFeeStruct}

        // Maps a function name to a DynamicFeeStruct
        pub var dynamicFees: {String: DynamicFeeStruct}

        init(_name: String, _title: String, _description: String, _version: String, _fixedFees: {String: FixedFeeStruct}, _dynamicFees: {String: DynamicFeeStruct}) {
            self.name = _name
            self.title = _title
            self.description = _description
            self.version = _version
            self.fixedFees = _fixedFees
            self.dynamicFees = _dynamicFees
        }
    }

    // FixedFeeStruct
    // Defines a struct for payment that
    // deals with fixed fees.
    //
    pub struct FixedFeeStruct {
        // The fixed fee.
        pub var amount: UFix64

        init(_amount: UFix64) {
            self.amount = _amount
        }
    }

    // DynamicFeeStruct
    // Defines a struct for payment that
    // deals with dynamic fees.
    //
    pub struct DynamicFeeStruct {
        // The minimum cost after calculation.
        pub var minimum: UFix64

        init(_minimum: UFix64) {
            self.minimum = _minimum
        }
    }

    pub resource interface IAuthNFT {
        pub let address: Address
    }

    // AuthNFT
    // The AuthNFT exists so an owner of a DappContract
    // can "register" with this HyperverseService contract in order
    // to use contracts that exist within the Hyperverse.
    //
    // In order to call paid functions that may or may not exist
    // within Hyperverse contracts, you must have an AuthNFT.
    //
    // This will only need to be acquired one time.
    //
    pub resource AuthNFT: IAuthNFT {
        pub let address: Address

        // The FlowToken Vault of the DappContract.
        // This is the vault that will be charged upon
        // calling charge().
        pub let flowTokenVault: Capability<&FlowToken.Vault>

        // fixedCharge
        // charge takes in a ContractMetadata (defined above) and a function name
        // that will exist within the fees dictionary inside contractMetadata.
        //
        // This function will be called by a contract within the Hyperverse
        // if it is a paid function.
        // 
        pub fun fixedCharge(contractMetadata: ContractMetadata, functionName: String) {
            ...
        }

        // dynamicCharge
        // charge takes in a ContractMetadata (defined above) and a function name
        // that will exist within the fees dictionary inside contractMetadata.
        //
        // This function will be called by a contract within the Hyperverse
        // if it is a paid function.
        // 
        pub fun dynamicCharge(contractMetadata: ContractMetadata, functionName: String, cost: UFix64) {
            ...
        }

        init(_address: Address, _flowTokenVault: Capability<&FlowToken.Vault>) {
            self.address = _address
            self.flowTokenVault = _flowTokenVault
        }

        // *(HyperverseService.currentHyperverseFee/(10000.0 as UFix64)
    }

    // register
    // register gets called by someone who has never registered with 
    // HyperverseService before.
    //
    // It returns a AuthNFT with a FlowToken vault that is passed in
    // as a parameter.
    //
    pub fun register(flowTokenVault: Capability<&FlowToken.Vault>): @AuthNFT {        
        assert(flowTokenVault.borrow() != nil, message: "This is not a correct FlowToken Vault Capability")
        return <- create AuthNFT(_address: flowTokenVault.borrow()!.owner!.address, _flowTokenVault: flowTokenVault)
    }

    init() {
        self.AuthStoragePath = /storage/HyperverseServiceAuthNFT

        ...
    }
}