import HyperverseInterface from "../HyperverseInterface.cdc"
import FlowToken from "../../Flow/FlowToken.cdc"
import HyperverseService from "../HyperverseService.cdc"
import FungibleToken from "../../Flow/FungibleToken.cdc"

// THIS DOES NOT IMPLEMENT IHyperverseModule BECAUSE IT'S NOT A SECONDARY EXPORT.
// IF WE WANTED TO MAKE IT A SECONDARY EXPORT, WE WOULD MAKE IT IMPLEMENT IHyperverseModule.
pub contract HyperverseSubscriptionContract: HyperverseInterface {

    // the total number of tenants that have been created
    pub var totalTenants: UInt64

    // All of the client Tenants (represented by Addresses) that 
    // have an instance of an Tenant and how many they have. 
    access(contract) var clientTenants: {Address: UInt64}

    pub resource interface ITenant {
        access(contract) var subscriptionTypes: {String: SubscriptionType}

        access(contract) var flowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>?
    }

    pub resource Tenant: ITenant, HyperverseInterface.ITenant {
        pub let id: UInt64 

        pub let authNFT: Capability<&HyperverseService.AuthNFT>

        // pub fun fixedCharge(functionName: String) {
        //    self.authNFT.borrow()!.fixedCharge(contractMetadata: HyperverseSubscriptionContract.contractMetadata, functionName: functionName)
        // }

        // pub fun dynamicCharge(functionName: String, cost: UFix64) {
        //    self.authNFT.borrow()!.dynamicCharge(contractMetadata: HyperverseSubscriptionContract.contractMetadata, functionName: functionName, cost: cost)
        // }

        // maps the SubscriptionType's name field to the actual
        // SubscriptionType
        pub var subscriptionTypes: {String: SubscriptionType}

        // The only purpose this serves is depositing into this vault
        // when someone subscribes, so we can keep this access(contract)
        // and have a simple setter.
        access(contract) var flowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>?

        pub fun addFlowTokenVault(flowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>) {
            self.flowTokenVault = flowTokenVault
        }

        access(self) var administrator: @Administrator

        // returns a reference to self.administrator so the admin
        // can perform actions with it
        pub fun adminRef(): &Administrator {
            return &self.administrator as &Administrator
        }

        init(_authNFT: Capability<&HyperverseService.AuthNFT>) {
            self.id = HyperverseSubscriptionContract.totalTenants
            HyperverseSubscriptionContract.totalTenants = HyperverseSubscriptionContract.totalTenants + (1 as UInt64)

            self.authNFT = _authNFT
            // initializes the contract by setting the proposals and votes to empty 
            // and creating a new Admin resource to put in storage
            self.subscriptionTypes = {}
            self.administrator <- create Administrator()
            self.flowTokenVault = nil
        }

        destroy() {
            destroy self.administrator
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

    init() {
        // Multitenancy
        self.clientTenants = {}

        self.totalTenants = 0
    }

    pub struct Subscription {
        pub let user: Address

        pub let startTime: UFix64

        pub let endTime: UFix64

        init(_user: Address, _duration: UFix64) {
            self.user = _user
            self.startTime = getCurrentBlock().timestamp
            self.endTime = getCurrentBlock().timestamp + _duration
        }
    }

    pub struct PublicFields {
        pub let name: String

        pub let title: String

        pub let description: String

        pub let period: String

        pub let count: UFix64

        pub var duration: UFix64

        pub let price: UFix64

        pub var active: Bool

        init(_name: String, _title: String, _description: String, _period: String, _count: UFix64, _price: UFix64, _active: Bool) {
            self.name = _name
            self.title = _title
            self.description = _description
            self.period = _period
            self.count = _count
            self.price = _price
            self.active = _active

            self.duration = 0.0
            if _period == "Minute" {
                self.duration = 60.0 * _count
            } else if _period == "Hour" {
                self.duration = 3600.0 * _count
            } else if _period == "Day" {
                self.duration = 86400.0 * _count
            } else if _period == "Week" {
                self.duration = 604800.0 * _count
            } else if _period == "Month" {
                self.duration = 2629743.0 * _count
            } else if _period == "Year" {
                self.duration = 31556926.0 * _count
            }
        }

        access(contract) fun flipActive() {
            self.active = !self.active
        }
    }

    pub struct SubscriptionType {
        pub var publicFields: PublicFields

        access(self) var subscribers: {Address: Subscription}

        init(_name: String, _title: String, _description: String, _period: String, _count: UFix64, _price: UFix64, _active: Bool) {
            self.publicFields = PublicFields(_name: _name, _title: _title, _description: _description, _period: _period, _count: _count, _price: _price, _active: _active)
            
            self.subscribers = {}
        }

        access(contract) fun isSubscribed(user: Address): Bool {
            if let subscription = self.subscribers[user] {
                if getCurrentBlock().timestamp > subscription.endTime {
                    self.subscribers[user] = nil
                    return false
                } else {
                    return true
                }
            } else {
                return false
            }
        }

        access(contract) fun subscribeUser(user: Address, userVault: &FlowToken.Vault, tenant: &Tenant{ITenant}) {
            pre {
                userVault.balance >= (self.publicFields.price):
                    "Not enough tokens to purchase the subscription!"
                self.publicFields.active:
                    "This subscription is not active!"
            }
            if self.isSubscribed(user: user) {
                panic("This user is already subscribed to thie SubscriptionType")
            } else {
                let newSubscriptionStruct = Subscription(_user: user, _duration: self.publicFields.duration)
                self.subscribers[user] = newSubscriptionStruct

                // CHANGE THIS AT SOME POINT to actually deposit into something
                let vault <- userVault.withdraw(amount: self.publicFields.price)
                tenant.flowTokenVault!.borrow()!.deposit(from: <-vault)
            }
        }
    }

    // Resource that the Administrator uses to add new
    // SubscriptionTypes
    pub resource Administrator {
        // adds a new SubscriptionType
        pub fun addSubscriptionType(tenant: &Tenant, name: String, title: String, description: String, period: String, count: UFix64, price: UFix64, active: Bool) {
            tenant.subscriptionTypes[name] = SubscriptionType(_name: name, _title: title, _description: description, _period: period, _count: count, _price: price, _active: active)
        }

        // turns subscription active
        pub fun flipSubscriptionActive(tenant: &Tenant, name: String) {
            tenant.subscriptionTypes[name]!.publicFields.flipActive()
        }
    }

    pub fun subscribeToType(tenant: &Tenant{ITenant}, subscriptionType: String, user: Address, userVault: &FlowToken.Vault) {
        let subscriptionTypeStruct: &SubscriptionType = &tenant.subscriptionTypes[subscriptionType]! as &SubscriptionType
    
        subscriptionTypeStruct.subscribeUser(user: user, userVault: userVault, tenant: tenant)
    }

    pub fun isSubscribedToType(tenant: &Tenant{ITenant}, subscriptionType: String, user: Address): Bool {
        let subscriptionTypeStruct = tenant.subscriptionTypes[subscriptionType]
            ?? panic("This SubscriptionType does not exist for this Tenant")
        
        return subscriptionTypeStruct.isSubscribed(user: user)
    }

    pub fun getSubscriptionType(tenant: &Tenant{ITenant}, subscriptionType: String): PublicFields {
        let subscriptionTypeStruct = tenant.subscriptionTypes[subscriptionType]!.publicFields
        
        return subscriptionTypeStruct
    }
}