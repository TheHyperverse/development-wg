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