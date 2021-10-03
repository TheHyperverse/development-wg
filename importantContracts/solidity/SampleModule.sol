// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

import "./IHyperverseModule.sol";

contract SampleModule is IHyperverseModule {
    constructor()
        IHyperverseModule(
            "SampleModule",
            Author(
                0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
                "https://externallink.net"
            ),
            "0.0.1",
            101,
            "https://externalLink.net",
            new bytes[](0)
        )
    {}
}
