/**

## The Decentology Multitenancy standard

## `HyperverseInterface` contract interface

The interface that all multitenant contracts should conform to.
If a user wants to deploy a new multitenant contract, their contract would need
to implement the Tenant interface.

Their contract would have to follow all the rules and naming
that the interface specifies.

## `totalTenants` UInt64

The number of Tenants that have been created.

## `contractMetadata` struct

Holds the contract's metadata. ContractMetadata is defined in
HyperverseService.

## `clientTenants` dictionary

A dictionary that maps the Address of a client to the amount of Tenants it has
created through calling `instance`.

## `ITenant` resource interface

Defines a publically viewable interface to read the id of a Tenant resource

## `Tenant` resource

The core resource type that represents an Tenant in the smart contract.

## `instance` function

A function that all clients can call to receive an Tenant resource. The client
passes in their Address so clientTenants can get updated.

## `getTenants` function

A function that returns clientTenants

*/

import HyperverseService from "./HyperverseService.cdc"

pub contract interface HyperverseInterface {

    // the total number of tenants that have been created
    pub var totalTenants: UInt64

    // Maps an address (of the customer/DappContract) to the amount
    // of tenants they have for a specific HyperverseContract.
    access(contract) var clientTenants: {Address: UInt64}

    pub resource interface ITenant {
        pub let id: UInt64
    }

    // Tenant
    // Requirement that all conforming multitenant smart contracts have
    // to define a resource called Tenant with a capability to a AuthNFT 
    // defined in HyperverseService and a charge function that charges that
    // AuthNFT.
    // 
    pub resource Tenant: ITenant {
        // the unique ID of the Tenant resource
        // that is initialized to be == totalTenants
        pub let id: UInt64

        // A capability to a AuthNFT so the charge function can
        // call charge on it.
        pub let authNFT: Capability<&HyperverseService.AuthNFT>
    }

    // instance
    // instance returns an Tenant resource.
    //
    pub fun instance(authNFT: Capability<&HyperverseService.AuthNFT>): @Tenant {
        pre {
            authNFT.borrow() != nil:
                "This is not a functioning AuthNFT Capability."
        }
    }

    // getTenants
    // getTenants returns clientTenants.
    //
    pub fun getTenants(): {Address: UInt64}
}
