---
layout: default
title: Delta Neutral Straddles
---

## Delta Neutral Straddles

Code replicating JUMP and VOL factors from [Cremers, Halling and Weinbaum (2014)](https://onlinelibrary.wiley.com/doi/abs/10.1111/jofi.12220) can be found [here](https://)

### Brief explanation

Cremers et al. (2014) suggests a way of constructing a trading strategy that will be exposed to jump risk. Their idea is the following. An option straddle position, where an investor is simultaneously long a call and a put of the same strike, is exposed to both Vega risk, the sensitivity of the position to the instantaneous volatility of the underlying and Gamma risk, the sensitivity of the position to large movements that can’t be delta hedged in the price of the underlying. If we want to isolate the second exposure, we need to construct a trading strategy that has zero Vega risk and positive Gamma risk. Cremers et al. (2014) uses two market neutral straddles of different maturities and weight them in such a way that the Vega of the resulting position is zero and Gamma is positive. This requires going long the closer maturity straddle and going short the farther maturity straddle.
