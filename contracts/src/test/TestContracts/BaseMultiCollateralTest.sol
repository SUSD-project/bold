// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {IBoldToken} from "../../Interfaces/IBoldToken.sol";
import {ICollateralRegistry} from "../../Interfaces/ICollateralRegistry.sol";
import {HintHelpers} from "../../HintHelpers.sol";
import {LiquityContracts} from "../../deployment.sol";

contract BaseMultiCollateralTest {
    struct Contracts {
        ICollateralRegistry collateralRegistry;
        IBoldToken boldToken;
        HintHelpers hintHelpers;
        LiquityContracts[] branches;
    }

    ICollateralRegistry collateralRegistry;
    IBoldToken boldToken;
    HintHelpers hintHelpers;
    LiquityContracts[] branches;

    function setupContracts(Contracts memory contracts) internal {
        collateralRegistry = contracts.collateralRegistry;
        boldToken = contracts.boldToken;
        hintHelpers = contracts.hintHelpers;

        for (uint256 i = 0; i < contracts.branches.length; ++i) {
            branches.push(contracts.branches[i]);
        }
    }
}