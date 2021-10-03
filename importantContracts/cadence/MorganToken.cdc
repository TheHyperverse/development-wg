import HyperverseService from "../HyperverseService.cdc"
import IHyperverseComposable from "../IHyperverseComposable.cdc"
import IHyperverseModule from "../IHyperverseModule.cdc"
import HyperverseModule from "../HyperverseModule.cdc"

// THE FIRST EXAMPLE OF A SMART MODULE

// THIS DOES IMPLEMENT IHyperverseModule BECAUSE IT IS A SECONDARY EXPORT (aka Module).
// IT DOES IMPLEMENT IHyperverseComposable BECAUSE IT'S A SMART COMPOSABLE CONTRACT.
pub contract MorganToken: IHyperverseModule, IHyperverseComposable {

    // must be access(contract) because dictionaries can be
    // changed if they're pub
    access(contract) let metadata: HyperverseModule.ModuleMetadata
    
    /* Requirements for the IHyperverseComposable */

    // the total number of tenants that have been created
    pub var totalTenants: UInt64

    // All of the client Tenants (represented by Addresses) that 
    // have an instance of an Tenant and how many they have. 
    access(contract) var clientTenants: {Address: UInt64}

    pub resource interface IVault {
        pub let id: UInt64
        access(contract) fun burnTotalSupply(amount: UFix64)
        access(contract) fun addTotalSupply(amount: UFix64)
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, IVault {
        pub let id: UInt64 

        pub let authNFT: Capability<&HyperverseService.AuthNFT>

        /* For MorganToken Functionality */

        pub var totalSupply: UFix64

        pub fun burnTotalSupply(amount: UFix64) {
            self.totalSupply = self.totalSupply - amount
        }

         pub fun addTotalSupply(amount: UFix64) {
            self.totalSupply = self.totalSupply + amount
        }

        pub var admin: @Administrator

        pub fun adminRef(): &Administrator {
            return &self.admin as &Administrator
        }

        init(_authNFT: Capability<&HyperverseService.AuthNFT>) {
            /* For Composability */
            self.id = MorganToken.totalTenants
            MorganToken.totalTenants = MorganToken.totalTenants + (1 as UInt64)
            self.authNFT = _authNFT

            /* For MorganToken Functionality */
            self.totalSupply = 0.0
            self.admin <- create Administrator()
        }

        destroy() {
            destroy self.admin
        }
    }

    pub fun instance(authNFT: Capability<&HyperverseService.AuthNFT>): @Tenant {
        let clientTenant = authNFT.borrow()!.owner!.address
        if let count = self.clientTenants[clientTenant] {
            self.clientTenants[clientTenant] = self.clientTenants[clientTenant]! + (1 as UInt64)
        } else {
            self.clientTenants[clientTenant] = (1 as UInt64)
        }

        return <-create Tenant(_authNFT: authNFT)
    }

    pub fun getTenants(): {Address: UInt64} {
        return self.clientTenants
    }

    /* Functionality of the Morgan Token Module */

  
    pub resource interface Provider {
        pub fun withdraw(amount: UFix64): @Vault {
            post {
                // `result` refers to the return value
                result.balance == amount:
                    "Withdrawal amount must be the same as the balance of the withdrawn Vault"
            }
        }
    }

    pub resource interface Receiver {
        pub fun deposit(vault: @Vault)
    }

    pub resource interface Balance {
        pub var balance: UFix64

        init(_balance: UFix64, _tenantVaultRef: Capability<&Tenant{IVault}>) {
            post {
                self.balance == _balance:
                    "Balance must be initialized to the initial balance"
            }
        }
    }

    pub resource Vault: Provider, Receiver, Balance {
        pub var balance: UFix64
        // Needed for two main reasons:
        // 1) To ensure tokens in this Vault are from the same Tenant (ecosystem)
        // 2) For burning tokens and taking supply away
        pub var tenantVaultRef: Capability<&Tenant{IVault}>

        pub fun withdraw(amount: UFix64): @MorganToken.Vault {
            self.balance = self.balance - amount
            return <-create Vault(_balance: amount, _tenantVaultRef: self.tenantVaultRef)
        }

        pub fun deposit(vault: @MorganToken.Vault) {
            // Makes sure that the tokens being deposited are from the
            // same Tenant. That's why we need the Tenant's id.
            pre {
                vault.tenantVaultRef.borrow()!.id == self.tenantVaultRef.borrow()!.id:
                    "Trying to deposit Morgan Token that belongs to another Tenant"
            }
            self.balance = self.balance + vault.balance
            vault.balance = 0.0
            destroy vault
        }

        init(_balance: UFix64, _tenantVaultRef: Capability<&Tenant{IVault}>) {
            self.balance = _balance
            self.tenantVaultRef = _tenantVaultRef
        }

        destroy() {
            self.tenantVaultRef.borrow()!.burnTotalSupply(amount: self.balance)
        }
    }

    pub fun createEmptyVault(tenantVaultRef: Capability<&Tenant{IVault}>): @Vault {
        return <-create Vault(_balance: 0.0, _tenantVaultRef: tenantVaultRef)
    }

    pub resource Administrator {
        pub fun createNewMinter(tenantVaultRef: Capability<&Tenant{IVault}>): @Minter {
            return <-create Minter(_tenantVaultRef: tenantVaultRef)
        }
    }

    pub resource Minter {

        pub var tenantVaultRef: Capability<&Tenant{IVault}>

        pub fun mintTokens(amount: UFix64): @MorganToken.Vault {
            pre {
                amount > 0.0: "Amount minted must be greater than zero"
            }
            self.tenantVaultRef.borrow()!.addTotalSupply(amount: amount)
            return <-create Vault(_balance: amount, _tenantVaultRef: self.tenantVaultRef)
        }

        init(_tenantVaultRef: Capability<&Tenant{IVault}>) {
           self.tenantVaultRef = _tenantVaultRef
        }
    }

    init() {
        /* For Secondary Export */
        self.clientTenants = {}
        self.totalTenants = 0

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "Morgan Token", 
            _authors: [HyperverseModule.Author(_address: 0x1, _external: "https://localhost:5000/externalMetadata")], 
            _version: "0.0.1", 
            _publishedAt: 1632887513,
            _tenantStoragePath: /storage/MorganTokenTenant,
            _external: "https://externalLink.net/1234567890",
            _secondaryModules: nil
        )
    }
}