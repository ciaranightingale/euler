const et = require('./lib/eTestLib');

et.testSet({
    desc: "deposit/withdraw balances, with interest",

    preActions: ctx => {
        let actions = [];

        for (let from of [ctx.wallet, ctx.wallet2]) {
            actions.push({ from, send: 'tokens.TST.mint', args: [from.address, et.eth(100)], });
            actions.push({ from, send: 'tokens.TST.approve', args: [ctx.contracts.euler.address, et.MaxUint256,], });
        }

        for (let from of [ctx.wallet4]) {
            actions.push({ from, send: 'tokens.TST2.mint', args: [from.address, et.eth(100)], });
            actions.push({ from, send: 'tokens.TST2.approve', args: [ctx.contracts.euler.address, et.MaxUint256,], });
            actions.push({ from, send: 'markets.enterMarket', args: [0, ctx.contracts.tokens.TST2.address], },);
            actions.push({ from, send: 'eTokens.eTST2.deposit', args: [0, et.eth(50)], });
        }

        actions.push({ action: 'updateUniswapPrice', pair: 'TST/WETH', price: '.1', });
        actions.push({ action: 'updateUniswapPrice', pair: 'TST2/WETH', price: '.2', });

        actions.push({ action: 'jumpTime', time: 31*60, });

        return actions;
    },
})


.test({
    desc: "basic interest earning flow",
    actions: ctx => [
        { send: 'eTokens.eTST.deposit', args: [0, et.eth(1)], },
        { call: 'eTokens.eTST.balanceOfUnderlying', args: [ctx.wallet.address], assertEql: et.eth(1), },
        { call: 'eTokens.eTST.balanceOf', args: [ctx.wallet.address], assertEql: et.eth(1), },

        { action: 'setIRM', underlying: 'TST', irm: 'IRM_FIXED', },

        { from: ctx.wallet4, send: 'dTokens.dTST.borrow', args: [0, et.eth(1)], },
        { action: 'checkpointTime', },

        { call: 'tokens.TST.balanceOf', args: [ctx.wallet4.address], assertEql: et.eth(1), },
        { call: 'dTokens.dTST.balanceOf', args: [ctx.wallet4.address], assertEql: et.eth('1.000000000000000001'), },

        // Go ahead 1 year (+ 1 second because I did it this way by accident at first, don't want to bother redoing calculations below)

        { action: 'jumpTime', time: 365*86400 + 1, },
        { action: 'setIRM', underlying: 'TST', irm: 'IRM_ZERO', },

        // 10% APR interest accrued:
        { call: 'dTokens.dTST.balanceOf', args: [ctx.wallet4.address], assertEql: et.eth('1.105170921404897917'), },

        // eToken balanceOf unchanged:
        { call: 'eTokens.eTST.balanceOf', args: [ctx.wallet.address], assertEql: et.eth(1), },

        // eToken balanceOfUnderlying increases (one less wei than the amount owed):
        { call: 'eTokens.eTST.balanceOfUnderlying', args: [ctx.wallet.address], assertEql: et.eth('1.105170921404897916'), },

        // Now wallet2 deposits and gets different exchange rate
        { call: 'eTokens.eTST.balanceOf', args: [ctx.wallet2.address], assertEql: et.eth(0), },
        { from: ctx.wallet2, send: 'eTokens.eTST.deposit', args: [0, et.eth(1)], },
        { call: 'eTokens.eTST.balanceOfUnderlying', args: [ctx.wallet2.address], assertEql: et.eth('0.999999999999999999'), },
        { call: 'eTokens.eTST.balanceOf', args: [ctx.wallet2.address], assertEql: et.eth('0.904837415310199983'), },

        // Go ahead 1 year

        { action: 'setIRM', underlying: 'TST', irm: 'IRM_FIXED', },
        { action: 'checkpointTime', },
        { action: 'jumpTime', time: 365*86400, },
        { action: 'setIRM', underlying: 'TST', irm: 'IRM_ZERO', },

        // balanceOf calls stay the same

        { call: 'eTokens.eTST.balanceOf', args: [ctx.wallet.address], assertEql: et.eth(1), },
        { call: 'eTokens.eTST.balanceOf', args: [ctx.wallet2.address], assertEql: et.eth('0.904837415310199983'), },
        { call: 'eTokens.eTST.totalSupply', args: [], assertEql: et.eth('1.904837415310199983'), },

        // Earnings:

        { call: 'eTokens.eTST.balanceOfUnderlying', args: [ctx.wallet.address], assertEql: et.eth('1.166190218541122110'), },
        { call: 'eTokens.eTST.balanceOfUnderlying', args: [ctx.wallet2.address], assertEql: et.eth('1.055212543104786187'), },
        { call: 'eTokens.eTST.totalSupplyUnderlying', args: [], assertEql: et.eth('2.221402761645908297'), },

        // More interest is now owed:

        { call: 'dTokens.dTST.balanceOf', args: [ctx.wallet4.address], assertEql: et.eth('1.221402761645908299'), },

        // Additional interest owed = 1.221402761645908299 - 1.105170921404897917 = 0.116231840241010382

        // Total additional earnings: (1.166190218541122110 - 1.105170921404897916) + (1.055212543104786187 - 1) = 0.116231840241010381
        // This matches the additional interest owed (except for the rounding increase)

        // wallet1 has earned more because it started with larger balance. wallet2 should have earned:
        // 0.116231840241010382 / (1 + 1.105170921404897917) = 0.05521254310478618771
        // ... which matches, after truncating to 18 decimals.
    ],
})


.run();
