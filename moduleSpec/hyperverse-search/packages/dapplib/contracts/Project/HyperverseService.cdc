import FlowToken from "../Flow/FlowToken.cdc"
import FungibleToken from "../Flow/FungibleToken.cdc"

// Has to do with payments, fees, tokenomics, etc
pub contract HyperverseService {

    // Named Paths
    //
    pub let AuthStoragePath: StoragePath

    // Decentology's FlowToken Vault. Fees that are owed to Decentology
    // will be deposited here. This Vault can also be changed by an Admin resource
    // defined below.
    access(contract) var DecentologyVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>?

    // Represented in basis points (0 <= currentHyperverseFee <= 10000)
    // to determine what percent of the dynamicFee will be deposited into
    // DecentologyVault.
    pub var currentHyperverseFee: UFix64

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

    // Admin
    // The Admin resource exists in order to change
    // DecentologyVault and currentHyperverseFee.
    //
    pub resource Admin {
        // changeDecentologyVault
        // Changes DecentologyVault.
        //
        pub fun changeDecentologyVault(newVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>) {
            HyperverseService.DecentologyVault = newVault
        }

        // changeHyperverseFee
        // Changes currentHyperverseFee.
        // newFee must be between 0 and 10000
        //
        pub fun changeHyperverseFee(newFee: UFix64) {
            pre {
                newFee >= 0.0 && newFee <= 10000.0:
                    "newFee must be between 0-10,000 in basis points"
            }
            HyperverseService.currentHyperverseFee = newFee
        }

        // createAdmin
        // Creates and returns a new Admin resource.
        //
        pub fun createAdmin(): @Admin {
            return <- create Admin()
        }

        init() {

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

        // pub fun fixedCharge(contractMetadata: ContractMetadata, functionName: String) {
            
        // }

        // dynamicCharge
        // charge takes in a ContractMetadata (defined above) and a function name
        // that will exist within the fees dictionary inside contractMetadata.
        //
        // This function will be called by a contract within the Hyperverse
        // if it is a paid function.
        // 

        // pub fun dynamicCharge(contractMetadata: ContractMetadata, functionName: String, cost: UFix64) {
            
        // }

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

        self.DecentologyVault = nil
        self.currentHyperverseFee = 0.0

        self.account.save(<-create Admin(), to: /storage/HyperverseServiceAdmin)
    }
}