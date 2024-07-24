pragma solidity ^0.8.18;

import "./TestContracts/DevTestSetup.sol";

contract BatchManagementFeeTest is DevTestSetup {
    function testAdjustTroveMintsFeeForBatch() public {
        // Open 2 troves in the same batch manager
        uint256 troveId = openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        openTroveAndJoinBatchManager(C, 200e18, 5000e18, B, 5e16);

        vm.warp(block.timestamp + 10 days);

        uint256 batchInitialBalance = boldToken.balanceOf(B);
        uint256 batchAccruedManagementFee = troveManager.calcBatchAccruedManagementFee(B);

        // Adjust first trove
        addColl(A, troveId, 1 ether);

        assertEq(boldToken.balanceOf(B), batchInitialBalance + batchAccruedManagementFee);
    }

    function testAdjustTroveIncreasesTroveDebtByFee() public {
        // Open 2 troves in the same batch manager
        uint256 troveId = openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        openTroveAndJoinBatchManager(C, 200e18, 5000e18, B, 5e16);

        vm.warp(block.timestamp + 10 days);

        uint256 troveInitialDebt = troveManager.getTroveDebt(troveId);
        uint256 troveAccruedInterest = troveManager.calcTroveAccruedInterest(troveId);
        uint256 troveAccruedManagementFee = troveManager.calcTroveAccruedBatchManagementFee(troveId);

        // Adjust first trove
        addColl(A, troveId, 1 ether);

        assertEq(
            troveManager.getTroveDebt(troveId), troveInitialDebt + troveAccruedInterest + troveAccruedManagementFee
        );
    }

    function testAdjustTroveIncreasesDebtInActivePoolByFee() public {
        // Open 2 troves in the same batch manager
        uint256 troveId = openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        openTroveAndJoinBatchManager(C, 200e18, 5000e18, B, 5e16);

        vm.warp(block.timestamp + 10 days);

        uint256 activePoolInitialDebt = activePool.aggRecordedDebt();
        uint256 batchAccruedInterest = troveManager.calcBatchAccruedInterest(B);
        uint256 batchAccruedManagementFee = troveManager.calcBatchAccruedManagementFee(B);

        // Adjust first trove
        addColl(A, troveId, 1 ether);

        assertApproxEqAbs(
            activePool.aggRecordedDebt(), activePoolInitialDebt + batchAccruedInterest + batchAccruedManagementFee, 1
        );
    }

    function testCloseTroveMintsFeeForBatch() public {
        // Open 2 troves in the same batch manager
        uint256 troveId = openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        openTroveAndJoinBatchManager(C, 200e18, 5000e18, B, 5e16);
        // C sends to A so A can repay and close
        transferBold(C, A, 5000e18);

        vm.warp(block.timestamp + 10 days);

        uint256 batchInitialBalance = boldToken.balanceOf(B);
        uint256 batchAccruedManagementFee = troveManager.calcBatchAccruedManagementFee(B);

        // Close first trove
        closeTrove(A, troveId);

        assertEq(boldToken.balanceOf(B), batchInitialBalance + batchAccruedManagementFee);
    }

    function testCloseTroveIncreasesTroveDebtFee() public {
        // Open 2 troves in the same batch manager
        uint256 troveId = openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        openTroveAndJoinBatchManager(C, 200e18, 5000e18, B, 5e16);
        // C sends to A so A can repay and close
        transferBold(C, A, 5000e18);

        vm.warp(block.timestamp + 10 days);

        uint256 AIntialBalance = boldToken.balanceOf(A);
        uint256 troveInitialDebt = troveManager.getTroveDebt(troveId);
        uint256 troveAccruedInterest = troveManager.calcTroveAccruedInterest(troveId);
        uint256 troveAccruedManagementFee = troveManager.calcTroveAccruedBatchManagementFee(troveId);

        // Close first trove
        closeTrove(A, troveId);

        assertEq(
            AIntialBalance - boldToken.balanceOf(A), troveInitialDebt + troveAccruedInterest + troveAccruedManagementFee
        );
    }

    function testCloseTroveBatchManagementFeeDoesNotIncreaseDebtInActivePool() public {
        // Open 2 troves in the same batch manager
        uint256 ATroveId = openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        uint256 BTroveId = openTroveAndJoinBatchManager(C, 200e18, 5000e18, B, 5e16);
        // C sends to A so A can repay and close
        transferBold(C, A, 5000e18);

        vm.warp(block.timestamp + 10 days);

        // Close first trove
        closeTrove(A, ATroveId);

        assertApproxEqAbs(activePool.aggRecordedDebt(), troveManager.getTroveEntireDebt(BTroveId), 1);
    }

    function testChangeBatchInterestRateMintsFeeForBatch() public {
        // Open 2 troves in the same batch manager
        openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        openTroveAndJoinBatchManager(C, 200e18, 5000e18, B, 5e16);

        vm.warp(block.timestamp + 10 days);

        uint256 batchInitialBalance = boldToken.balanceOf(B);
        uint256 batchAccruedManagementFee = troveManager.calcBatchAccruedManagementFee(B);

        // Change batch interest rate
        setBatchInterestRate(B, 10e16);

        assertEq(boldToken.balanceOf(B), batchInitialBalance + batchAccruedManagementFee);
    }

    function testChangeBatchInterestRateIncreasesTroveDebtByFee() public {
        // Open 2 troves in the same batch manager
        uint256 troveId = openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        openTroveAndJoinBatchManager(C, 200e18, 5000e18, B, 5e16);

        vm.warp(block.timestamp + 10 days);

        uint256 troveInitialDebt = troveManager.getTroveDebt(troveId);
        uint256 troveAccruedInterest = troveManager.calcTroveAccruedInterest(troveId);
        uint256 troveAccruedManagementFee = troveManager.calcTroveAccruedBatchManagementFee(troveId);

        // Change batch interest rate
        setBatchInterestRate(B, 10e16);

        assertEq(
            troveManager.getTroveDebt(troveId), troveInitialDebt + troveAccruedInterest + troveAccruedManagementFee
        );
    }

    function testChangeBatchInterestRateIncreasesDebtInActivePoolByFee() public {
        // Open 2 troves in the same batch manager
        openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        openTroveAndJoinBatchManager(C, 200e18, 5000e18, B, 5e16);

        vm.warp(block.timestamp + 10 days);

        uint256 activePoolInitialDebt = activePool.aggRecordedDebt();
        uint256 batchAccruedInterest = troveManager.calcBatchAccruedInterest(B);
        uint256 batchAccruedManagementFee = troveManager.calcBatchAccruedManagementFee(B);

        // Change batch interest rate
        setBatchInterestRate(B, 10e16);

        assertApproxEqAbs(
            activePool.aggRecordedDebt(), activePoolInitialDebt + batchAccruedInterest + batchAccruedManagementFee, 1
        );
    }

    function testAddTroveToBatchMintsFeeForBatch() public {
        // Open 2 troves, 1 in a batch manager, 1 alone
        openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        uint256 troveId = openTroveNoHints100pct(C, 200 ether, 5000e18, 10e16);

        vm.warp(block.timestamp + 10 days);

        uint256 batchInitialBalance = boldToken.balanceOf(B);
        uint256 batchAccruedManagementFee = troveManager.calcBatchAccruedManagementFee(B);

        // Add trove to batch
        setInterestBatchManager(C, troveId, B);

        assertEq(boldToken.balanceOf(B), batchInitialBalance + batchAccruedManagementFee);
    }

    function testAddTroveToBatchDoesNotIncreaseTroveDebtByFee() public {
        // Open 2 troves, 1 in a batch manager, 1 alone
        openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        uint256 troveId = openTroveNoHints100pct(C, 200 ether, 5000e18, 10e16);

        vm.warp(block.timestamp + 10 days);

        uint256 troveInitialDebt = troveManager.getTroveDebt(troveId);
        uint256 troveAccruedInterest = troveManager.calcTroveAccruedInterest(troveId);
        uint256 troveAccruedManagementFee = troveManager.calcTroveAccruedBatchManagementFee(troveId);
        assertEq(troveAccruedManagementFee, 0, "Trove accrued fee should be zero");

        // Add trove to batch
        setInterestBatchManager(C, troveId, B);

        assertApproxEqAbs(troveManager.getTroveDebt(troveId), troveInitialDebt + troveAccruedInterest, 1);
    }

    function testAddTroveToBatchIncreasesDebtInActivePoolByFee() public {
        // Open 2 troves, 1 in a batch manager, 1 alone
        openTroveAndJoinBatchManager(A, 100 ether, 5000e18, B, 5e16);
        uint256 troveId = openTroveNoHints100pct(C, 200 ether, 5000e18, 10e16);

        vm.warp(block.timestamp + 10 days);

        uint256 activePoolInitialDebt = activePool.aggRecordedDebt();
        uint256 batchAccruedInterest = troveManager.calcBatchAccruedInterest(B);
        uint256 batchAccruedManagementFee = troveManager.calcBatchAccruedManagementFee(B);
        uint256 troveAccruedInterest = troveManager.calcTroveAccruedInterest(troveId);

        // Add trove to batch
        setInterestBatchManager(C, troveId, B);

        assertApproxEqAbs(
            activePool.aggRecordedDebt(),
            activePoolInitialDebt + batchAccruedInterest + batchAccruedManagementFee + troveAccruedInterest,
            10
        );
    }

    function testSwitchTroveBatchMintsFeeForBatches() public {
        // Open 2 troves in 2 different batch managers
        openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        uint256 troveId = openTroveAndJoinBatchManager(C, 100e18, 5000e18, D, 5e16);

        vm.warp(block.timestamp + 10 days);

        // Batch B
        uint256 batchBInitialBalance = boldToken.balanceOf(B);
        uint256 batchBAccruedManagementFee = troveManager.calcBatchAccruedManagementFee(B);
        // Batch D
        uint256 batchDInitialBalance = boldToken.balanceOf(D);
        uint256 batchDAccruedManagementFee = troveManager.calcBatchAccruedManagementFee(D);

        // Switch trove batch
        switchBatchManager(C, troveId, B);

        assertEq(boldToken.balanceOf(B), batchBInitialBalance + batchBAccruedManagementFee);
        assertEq(boldToken.balanceOf(D), batchDInitialBalance + batchDAccruedManagementFee);
    }

    function testSwitchTroveBatchIncreasesTroveDebtByFee() public {
        // Open 2 troves in 2 different batch managers
        openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        uint256 troveId = openTroveAndJoinBatchManager(C, 100e18, 5000e18, D, 5e16);

        vm.warp(block.timestamp + 10 days);

        uint256 troveInitialDebt = troveManager.getTroveDebt(troveId);
        uint256 troveAccruedInterest = troveManager.calcTroveAccruedInterest(troveId);
        uint256 troveAccruedManagementFee = troveManager.calcTroveAccruedBatchManagementFee(troveId);

        // Switch trove batch
        switchBatchManager(C, troveId, B);

        assertEq(
            troveManager.getTroveDebt(troveId), troveInitialDebt + troveAccruedInterest + troveAccruedManagementFee
        );
    }

    function testSwitchTroveBatchIncreasesDebtInActivePoolByFee() public {
        // Open 2 troves in 2 different batch managers
        openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        uint256 troveId = openTroveAndJoinBatchManager(C, 100e18, 5000e18, D, 5e16);

        vm.warp(block.timestamp + 10 days);

        uint256 activePoolInitialDebt = activePool.aggRecordedDebt();
        uint256 batchBAccruedInterest = troveManager.calcBatchAccruedInterest(B);
        uint256 batchBAccruedManagementFee = troveManager.calcBatchAccruedManagementFee(B);
        uint256 batchDAccruedInterest = troveManager.calcBatchAccruedInterest(B);
        uint256 batchDAccruedManagementFee = troveManager.calcBatchAccruedManagementFee(B);

        // Switch trove batch
        uint256 upfrontFee = predictAdjustInterestRateUpfrontFee(troveId, 5e16);
        switchBatchManager(C, troveId, B);

        assertApproxEqAbs(
            activePool.aggRecordedDebt(),
            activePoolInitialDebt + batchBAccruedInterest + batchBAccruedManagementFee + batchDAccruedInterest
            + batchDAccruedManagementFee + upfrontFee,
            10
        );
    }

    function testRemoveTroveFromBatchMintsFeeForBatch() public {
        // Open 2 troves in the same batch
        openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        uint256 troveId = openTroveAndJoinBatchManager(C, 100e18, 5000e18, B, 5e16);

        vm.warp(block.timestamp + 10 days);

        uint256 batchInitialBalance = boldToken.balanceOf(B);
        uint256 batchAccruedManagementFee = troveManager.calcBatchAccruedManagementFee(B);

        // Add trove to batch
        removeFromBatch(C, troveId, 10e16);

        assertEq(boldToken.balanceOf(B), batchInitialBalance + batchAccruedManagementFee);
    }

    function testRemoveTroveFromBatchIncreasesTroveDebtByFee() public {
        // Open 2 troves in the same batch
        openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        uint256 troveId = openTroveAndJoinBatchManager(C, 100e18, 5000e18, B, 5e16);

        vm.warp(block.timestamp + 10 days);

        uint256 troveInitialDebt = troveManager.getTroveDebt(troveId);
        uint256 troveAccruedInterest = troveManager.calcTroveAccruedInterest(troveId);
        uint256 troveAccruedManagementFee = troveManager.calcTroveAccruedBatchManagementFee(troveId);

        // Add trove to batch
        removeFromBatch(C, troveId, 10e16);

        assertEq(
            troveManager.getTroveDebt(troveId), troveInitialDebt + troveAccruedInterest + troveAccruedManagementFee
        );
    }

    function testRemoveTroveFromBatchIncreasesDebtInActivePoolByFee() public {
        // Open 2 troves in the same batch
        openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        uint256 troveId = openTroveAndJoinBatchManager(C, 100e18, 5000e18, B, 5e16);

        vm.warp(block.timestamp + 10 days);

        uint256 activePoolInitialDebt = activePool.aggRecordedDebt();
        uint256 batchAccruedInterest = troveManager.calcBatchAccruedInterest(B);
        uint256 batchAccruedManagementFee = troveManager.calcBatchAccruedManagementFee(B);

        // Add trove to batch
        removeFromBatch(C, troveId, 10e16);

        assertApproxEqAbs(
            activePool.aggRecordedDebt(), activePoolInitialDebt + batchAccruedInterest + batchAccruedManagementFee, 1
        );
    }

    function testAfterBatchManagementFeeAccrualEntireSystemDebtMatchesWithOpenTrove() public {
        // Open 1 troves in a batch
        uint256 ATroveId = openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);

        vm.warp(block.timestamp + 10 days);

        uint256 entireSystemDebt = troveManager.getEntireSystemDebt();
        uint256 entireDebtA = troveManager.getTroveEntireDebt(ATroveId);
        assertApproxEqAbs(entireSystemDebt, entireDebtA, 1, "Entire debt should be that of trove A");

        // another trove joins the batch
        uint256 CTroveId = openTroveAndJoinBatchManager(C, 100e18, 4000e18, B, 5e16);

        vm.warp(block.timestamp + 5 days);

        entireSystemDebt = troveManager.getEntireSystemDebt();
        entireDebtA = troveManager.getTroveEntireDebt(ATroveId);
        uint256 entireDebtC = troveManager.getTroveEntireDebt(CTroveId);
        assertApproxEqAbs(entireSystemDebt, entireDebtA + entireDebtC, 10, "Entire debt should be A+C");
    }

    function testAfterBatchManagementFeeAccrualEntireSystemDebtMatchesWithSwitchBatch() public {
        // Open 2 troves in the same batch
        uint256 ATroveId = openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        uint256 CTroveId = openTroveAndJoinBatchManager(C, 100e18, 4000e18, B, 5e16);

        vm.warp(block.timestamp + 10 days);

        // Second trove changes batch (with a different fee)
        registerBatchManager(D, uint128(MIN_ANNUAL_INTEREST_RATE), 1e18, 4e16, 50e14, 0);
        // Switch trove batch
        switchBatchManager(C, CTroveId, D);

        vm.warp(block.timestamp + 5 days);

        uint256 entireSystemDebt = troveManager.getEntireSystemDebt();
        uint256 entireDebtA = troveManager.getTroveEntireDebt(ATroveId);
        uint256 entireDebtC = troveManager.getTroveEntireDebt(CTroveId);
        assertApproxEqAbs(entireSystemDebt, entireDebtA + entireDebtC, 10);
    }

    function testAfterBatchManagementFeeAccrualEntireSystemDebtMatchesWithRemoveBatch() public {
        // Open 2 troves in the same batch
        uint256 ATroveId = openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        uint256 CTroveId = openTroveAndJoinBatchManager(C, 100e18, 4000e18, B, 5e16);

        vm.warp(block.timestamp + 10 days);

        // First trove leaves the batch
        removeFromBatch(A, ATroveId, 3e16);

        vm.warp(block.timestamp + 5 days);

        uint256 entireSystemDebt = troveManager.getEntireSystemDebt();
        uint256 entireDebtA = troveManager.getTroveEntireDebt(ATroveId);
        uint256 entireDebtC = troveManager.getTroveEntireDebt(CTroveId);
        assertApproxEqAbs(entireSystemDebt, entireDebtA + entireDebtC, 3);
    }

    function testAfterBatchManagementFeeAccrualEntireSystemDebtMatchesWithCloseTrove() public {
        // Open 2 troves in the same batch
        uint256 ATroveId = openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        uint256 CTroveId = openTroveAndJoinBatchManager(C, 100e18, 4000e18, B, 5e16);

        // Second trove closes
        transferBold(A, C, 4000e18);
        closeTrove(C, CTroveId);

        vm.warp(block.timestamp + 15 days);

        uint256 entireSystemDebt = troveManager.getEntireSystemDebt();
        uint256 entireDebtA = troveManager.getTroveEntireDebt(ATroveId);
        assertApproxEqAbs(entireSystemDebt, entireDebtA, 1);
    }

    function testAfterBatchManagementFeeAccrualEntireSystemDebtMatchesWithLiquidateTroveOffset() public {
        priceFeed.setPrice(2000e18);
        // Open 2 troves in the same batch
        uint256 ATroveId = openTroveAndJoinBatchManager(A, 100 ether, 5000e18, B, 5e16);
        uint256 CTroveId = openTroveAndJoinBatchManager(C, 4 ether, 4000e18, B, 5e16);

        // A deposits to SP
        makeSPDepositAndClaim(A, 5000e18);

        vm.warp(block.timestamp + 5 days);

        // Second trove is liquidated
        priceFeed.setPrice(1100e18);
        liquidate(A, CTroveId);

        vm.warp(block.timestamp + 5 days);

        uint256 entireSystemDebt = troveManager.getEntireSystemDebt();
        uint256 entireDebtA = troveManager.getTroveEntireDebt(ATroveId);
        assertApproxEqAbs(entireSystemDebt, entireDebtA, 2);
    }

    function testAfterBatchManagementFeeAccrualEntireSystemDebtMatchesWithLiquidateTroveRedistribute() public {
        priceFeed.setPrice(2000e18);
        // Open 2 troves in the same batch
        uint256 ATroveId = openTroveAndJoinBatchManager(A, 100 ether, 5000e18, B, 5e16);
        uint256 CTroveId = openTroveAndJoinBatchManager(C, 4 ether, 4000e18, B, 5e16);

        vm.warp(block.timestamp + 5 days);

        // Second trove is liquidated
        priceFeed.setPrice(1100e18);
        liquidate(A, CTroveId);

        vm.warp(block.timestamp + 5 days);

        uint256 entireSystemDebt = troveManager.getEntireSystemDebt();
        uint256 entireDebtA = troveManager.getTroveEntireDebt(ATroveId);
        assertApproxEqAbs(entireSystemDebt, entireDebtA, 100);
    }

    function testAfterBatchManagementFeeAccrualEntireSystemDebtMatchesWithRedemption() public {
        // Open 2 troves in the same batch
        uint256 ATroveId = openTroveAndJoinBatchManager(A, 100e18, 5000e18, B, 5e16);
        uint256 CTroveId = openTroveAndJoinBatchManager(C, 100e18, 4000e18, B, 5e16);

        vm.warp(block.timestamp + 5 days);

        // A reedems 1k
        redeem(A, 1000e18);

        vm.warp(block.timestamp + 10 days);

        uint256 entireSystemDebt = troveManager.getEntireSystemDebt();
        uint256 entireDebtA = troveManager.getTroveEntireDebt(ATroveId);
        uint256 entireDebtC = troveManager.getTroveEntireDebt(CTroveId);
        assertApproxEqAbs(entireSystemDebt, entireDebtA + entireDebtC, 10);
    }
}
