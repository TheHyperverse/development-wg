// A module is something that has primary and secondary exports.

// The primary exported file has everything you need in it. All the functionality, all the metadata you need.
// It imports all of the contracts in the module into the primary export and that's the main module.

// On the side, there can be secondary exports that still implement the HyperverseModuleInterface.  
// They can all be exported just the same as modules, but they will only contain portions of the primary 
// export functionality.

pub contract HyperverseModule {
    
    // Has to exist with every exposed part of this module.
    // - Primary export (exactly one)
    // - Secondary exports (0 or more)
    // - ...
    pub struct ModuleMetadata {
        pub var title: String
        
        pub var authors: [Author]

        pub var version: String

        pub var publishedAt: UInt64

        pub var external: String

        pub var feeStructure: FeeStructure

        pub var secondaryModules: [String]?

        pub var license: String

        // tag for the module?
        pub var reviewed: Bool

        // ?? maybe
        pub var tags: {String: String}

        init(
            _title: String, 
            _authors: [Author], 
            _version: String, 
            _publishedAt: UInt64,
            _external: String,
            _feeStructure: FeeStructure,
            _secondaryModules: [String]?,
            _license: String,
            _reviewed: Bool,
            _tags: {String: String}
        ) {
            self.title = _title
            self.authors = _authors
            self.version = _version
            self.publishedAt = _publishedAt
            self.external = _external
            self.feeStructure = _feeStructure
            self.secondaryModules = _secondaryModules
            self.license = _license

            self.reviewed = _reviewed
            self.tags = _tags
        }
    }

    pub struct Author {
        // Option #1
        // Chain-native address
        pub var address: Address
        // All other chain addresses + any other metadata.
        pub var external: String


        // Option #2
        // optional
        pub var email: String

        // optional
        pub var name: String 

        pub var username: String 

        // maybe for each blockchain? {"Flow" : 0x01c...}, {"Ethereum" : 0xFlowIsBetter}
        pub var addresses: {String: String}

        // This will automatically be set to "Jacob Tucker" by default. 
        // If it is changed, we deduct 1,000,000 FlowToken from your account,
        // no give backs.
        pub var authorsFavoritePerson: String 

        // add more here

        init(_email: String, _name: String) {
            self.email = _email
            self.name = _name
            self.authorsFavoritePerson = "Jacob Tucker"
        }
    }

    pub struct FeeStructure {
        // discuss another time

        init() {
            
        }
    }
}