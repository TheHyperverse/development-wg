
import IHyperverseModule from "../IHyperverseModule.cdc"
import HyperverseModule from "../HyperverseModule.cdc"
pub contract PESubscription: IHyperverseModule {

    // must be access(contract) because dictionaries can be
    // changed if they're pub
    access(contract) let metadata: HyperverseModule.ModuleMetadata

    pub fun doAnything() {

    }

    init() {
        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "Subscription", 
            _authors: [HyperverseModule.Author(_email: "jacob@hiiii.com", _name: "Jacob Tucker")], 
            _version: "v0.1", 
            _publishedAt: 20141241313,
            _external: "https://externalLink.net/1234567890",
            _feeStructure: HyperverseModule.FeeStructure(),
            _secondaryModules: nil
        )
    }
}

