/**

## The Decentology Smart Module standard on Flow

## `IHyperverseModule` contract interface

The interface that all smart modules should conform to.
If a user wants to deploy a new smart module to the Hyperverse, 
their module would need to implement this contract interface.
This is a requirement for a primary exported contract, but also
can be used to create secondary exports as well.

Their contract would have to follow all the rules and naming
that the interface specifies.

## `metadata` HyperverseModule.ModuleMetadata

The metadata associated with this module. You can find the
definition for this metadata inside the `HyperverseModule` contract.

*/

// A module is something that has primary and secondary exports.

// The primary exported file has everything you need in it. All the functionality, all the metadata you need.
// It imports all of the contracts in the module into the primary export and that's the main module.

// On the side, there can be secondary exports that still implement the HyperverseModuleInterface.  
// They can all be exported just the same as modules, but they will only contain portions of the primary 
// export functionality.

import HyperverseModule from "./HyperverseModule.cdc"

pub contract interface IHyperverseModule {
    access(contract) let metadata: HyperverseModule.ModuleMetadata
}