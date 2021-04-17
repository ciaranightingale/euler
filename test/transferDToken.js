const et = require('./lib/eTestLib');

et.testSet({
    desc: "transfer dTokens",

    preActions: ctx => {
        let actions = [
            { action: 'setIRM', underlying: 'TST', irm: 'IRM_ZERO', },
        ];

        for (let from of [ctx.wallet, ctx.wallet2]) {
            actions.push({ from, send: 'tokens.TST.approve', args: [ctx.contracts.euler.address, et.MaxUint256,], });
            actions.push({ from, send: 'tokens.TST2.approve', args: [ctx.contracts.euler.address, et.MaxUint256,], });
        }

        for (let from of [ctx.wallet]) {
            actions.push({ from, send: 'tokens.TST.mint', args: [from.address, et.eth(100)], });
        }

        for (let from of [ctx.wallet2]) {
            actions.push({ from, send: 'tokens.TST2.mint', args: [from.address, et.eth(100)], });
        }

        actions.push({ from: ctx.wallet, send: 'eTokens.eTST.deposit', args: [0, et.eth(1)], });

        actions.push({ from: ctx.wallet2, send: 'eTokens.eTST2.deposit', args: [0, et.eth(50)], });
        actions.push({ from: ctx.wallet2, send: 'markets.enterMarket', args: [0, ctx.contracts.tokens.TST2.address], },);

        actions.push({ action: 'updateUniswapPrice', pair: 'TST/WETH', price: '.01', });
        actions.push({ action: 'updateUniswapPrice', pair: 'TST2/WETH', price: '.05', });

        actions.push({ action: 'jumpTime', time: 31*60, });

        return actions;
    },
})


.test({
    desc: "basic transfers to self",
    actions: ctx => [
        { from: ctx.wallet2, send: 'dTokens.dTST.borrow', args: [0, et.eth(.75)], },

        { call: 'dTokens.dTST.balanceOf', args: [ctx.wallet.address], assertEql: et.eth(0), },
        { call: 'dTokens.dTST.balanceOf', args: [ctx.wallet2.address], assertEql: et.eth(.75), },

        // can't just transfer to somebody else
        { from: ctx.wallet2, send: 'dTokens.dTST.transfer', args: [ctx.wallet.address, et.eth(.1)], expectError: 'insufficient-allowance', },

        // can't transferFrom to somebody else without an allowance
        { from: ctx.wallet2, send: 'dTokens.dTST.transferFrom', args: [ctx.wallet2.address, ctx.wallet.address, et.eth(.1)], expectError: 'insufficient-allowance', },

        // Just confirming wallet is *not* entered into TST
        { call: 'markets.getEnteredMarkets', args: [ctx.wallet.address],
          assertEql: [], },

        // but you can always transferFrom to yourself (assuming you have enough collateral)
        { from: ctx.wallet, send: 'dTokens.dTST.transferFrom', args: [ctx.wallet2.address, ctx.wallet.address, et.eth(.1)], },
        { call: 'dTokens.dTST.balanceOf', args: [ctx.wallet.address], assertEql: et.eth(.1), },
        { call: 'dTokens.dTST.balanceOf', args: [ctx.wallet2.address], assertEql: et.eth(.65), },

        // We're now entered into TST. This is sort of an edge case also: We're using TST as collateral *and* borrowing it
        { call: 'markets.getEnteredMarkets', args: [ctx.wallet.address],
          assertEql: [ctx.contracts.tokens.TST.address], },
    ],
})



.test({
    desc: "approvals",
    actions: ctx => [
        { from: ctx.wallet2, send: 'dTokens.dTST.borrow', args: [0, et.eth(.75)], },

        { call: 'dTokens.dTST.balanceOf', args: [ctx.wallet.address], assertEql: et.eth(0), },
        { call: 'dTokens.dTST.balanceOf', args: [ctx.wallet2.address], assertEql: et.eth(.75), },
        { call: 'dTokens.dTST.allowance', args: [ctx.wallet.address, ctx.wallet3.address], assertEql: 0, },

        // we're going to approve wallet3 to transfer dTokens to wallet

        { from: ctx.wallet3, send: 'dTokens.dTST.transferFrom', args: [ctx.wallet2.address, ctx.wallet.address, et.eth(.1)], expectError: 'insufficient-allowance', },

        { from: ctx.wallet, send: 'dTokens.dTST.approve', args: [ctx.wallet3.address, et.MaxUint256], },
        { call: 'dTokens.dTST.allowance', args: [ctx.wallet.address, ctx.wallet3.address], assertEql: et.MaxUint256, },

        { from: ctx.wallet3, send: 'dTokens.dTST.transferFrom', args: [ctx.wallet2.address, ctx.wallet.address, et.eth(.1)], },

        { call: 'dTokens.dTST.balanceOf', args: [ctx.wallet.address], assertEql: et.eth(.1), },
        { call: 'dTokens.dTST.balanceOf', args: [ctx.wallet2.address], assertEql: et.eth(.65), },

        // wallet3 can't transfer to wallet2 though

        { from: ctx.wallet3, send: 'dTokens.dTST.transferFrom', args: [ctx.wallet.address, ctx.wallet2.address, et.eth(.05)], expectError: 'insufficient-allowance', },

        // wallet2 still can't transfer to anyone
        { from: ctx.wallet2, send: 'dTokens.dTST.transferFrom', args: [ctx.wallet2.address, ctx.wallet.address, et.eth(.1)], expectError: 'insufficient-allowance',},
        { from: ctx.wallet2, send: 'dTokens.dTST.transferFrom', args: [ctx.wallet2.address, ctx.wallet3.address, et.eth(.1)], expectError: 'insufficient-allowance',},
        { from: ctx.wallet2, send: 'dTokens.dTST.transferFrom', args: [ctx.wallet.address, ctx.wallet3.address, et.eth(.1)], expectError: 'insufficient-allowance',},
        { from: ctx.wallet2, send: 'dTokens.dTST.transferFrom', args: [ctx.wallet3.address, ctx.wallet.address, et.eth(.1)], expectError: 'insufficient-allowance',},

        // and neither can wallet
        { from: ctx.wallet, send: 'dTokens.dTST.transferFrom', args: [ctx.wallet3.address, ctx.wallet2.address, et.eth(.1)], expectError: 'insufficient-allowance',},
        { from: ctx.wallet, send: 'dTokens.dTST.transferFrom', args: [ctx.wallet2.address, ctx.wallet3.address, et.eth(.1)], expectError: 'insufficient-allowance',},
    ],
})




.run();
