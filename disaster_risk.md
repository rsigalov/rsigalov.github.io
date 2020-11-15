---
layout: default
title: Disaster Risk
---

## Disaster Risk

Code can be found on [Github](https://github.com/rsigalov/disaster-risk-revision).

### Brief Overview

The code generates disaster measure introduced in [Siriwardane (2015)](https://www.hbs.edu/faculty/Publication%20Files/16-061_797fe134-9faa-4a5f-be41-1f1e5bebddcb.pdf). To do it
the code loads data on individual names options, fits SVI smiles into implied
volatilities and isolates the jump component following
[Du and Kapadia (2012)](https://people.umass.edu/nkapadia/docs/Du_Kapadia_August2012.pdf).
Prior research found that small companies are more correlated with real economic
activity. A disaster measure constructed from individual names rather than using
options of aggregate indices highlights levers this observation.
[Technical Appendix]({{site.url}}/papers/Disaster Risk Technical Appendix.pdf)
provides more details on estimation. [Details on Replication of Cremers JUMP and VOL factors]({{site.url}}/papers/Cremers JUMP and VOL factors technical details.pdf)

In the two figures below I show how the disaster measure estimated from
individual names options (Level D) compares with disaster measure estimated from
options on S&P 500 (S&P 500 D) with other measures of economic activity where
CP is the Cochrane-Piazzezi (2005) factor.

![Disaster Risk Compare 1]({{site.url}}/assets/images/compare_D_to_fin_market_indicators_1.png)
![Disaster Risk Compare 2]({{site.url}}/assets/images/compare_D_to_fin_market_indicators_2.png)

In the Figure below I show the contribution of different industries to the
disaster measure estimated using individual names options. In
particular, elevated disaster measure during the DotCom bubble is driven
primarily by *Business Equipment* industry (tech) and in the GFC by *Money*
industry (banks and insurance companies).

![Disaster Risk by Industry]({{site.url}}/assets/images/disaster_risk_industry.png)
