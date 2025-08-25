---
layout: default
title: Disaster Risk
---

## Disaster Risk (with Emil Siriwardane)

Code can be found on [Github](https://github.com/rsigalov/disaster-risk-revision).

### Brief Overview

The code generates disaster measure introduced in [Siriwardane (2015)](https://www.hbs.edu/faculty/Publication%20Files/16-061_797fe134-9faa-4a5f-be41-1f1e5bebddcb.pdf). A brief explanation for the disaster measure is provided in [This note]({{site.url}}/papers/VIV.pdf)

To construct the disaster measure
the code loads data on individual names options, fits Stochastic Volatility
Inspired smiles ([Zeliade's white paper](https://zeliade.com/wp-content/uploads/whitepapers/zwp-0005-SVICalibration.pdf))
into implied volatilities and isolates the jump component following
[Du and Kapadia (2012)](https://people.umass.edu/nkapadia/docs/Du_Kapadia_August2012.pdf).

Prior research found that small companies are more correlated with real economic
activity. A disaster measure constructed from individual names rather than using
options of aggregate indices levers this observation.
[Technical Appendix]({{site.url}}/papers/Disaster Risk Technical Appendix.pdf)
provides more details on estimation. [Details on Replication of Cremers JUMP and VOL factors]({{site.url}}/papers/Cremers JUMP and VOL factors technical details.pdf).


### Time series of disaster measure

In the two figures below I compare the disaster measure estimated from
individual names options (Level D) with disaster measure estimated from
options on S&P 500 (S&P 500 D) and with various valuation measures and
measures of economic activity

![Disaster Risk Compare 1]({{site.url}}/assets/images/compare_D_to_fin_market_indicators_1.png)
<!-- ![Disaster Risk Compare 2]({{site.url}}/assets/images/compare_D_to_fin_market_indicators_2.png) -->


### Industry composition

In the Figure below, I show the contribution of different industries to the
disaster measure estimated using individual names options. In
particular, elevated disaster measure during the DotCom bubble is driven
primarily by *Business Equipment* industry (tech) and in the GFC by *Money*
industry (banks and insurance companies).

![Disaster Risk by Industry]({{site.url}}/assets/images/disaster_risk_industry.png){: .center-image }

If we zoom in on the industry composition of disaster measure during 2020 presented
on the figure below, we can clearly see that contribution of industries that were 
hit by the COVID pandemic increased in March 2020. 

* *Oil* sector in the top left panel, *Transportation* and *Retail* sectors in the bottom
left panel, *Construction* in the top right panel, and *Finance* and *Lodging* in the bottom
right panel

![Disaster Risk by Industry During COVID]({{site.url}}/assets/images/industry_composition_covid.png)

### Characteristics of more and less exposed companies

After constructing the aggregate disaster measure discussed above we sort companies on
their exposure (beta), form portfolios and compare the average characteristics of the 
most and least exposed portfolios

* **Book-to-market** While outside large shocks such as the Great Recession and COVID pandemic
the book-to-market of most and least exposed firms is comparable, the most exposed firms
experience a much larger decline in market value raising their book-to-market significanty.
We can additionally see that the most exposed firms' book-to-market quickly reverts to levels
comparable with least exposed

![Comparing Book-to-Market across most and least exposed firms]({{site.url}}/assets/images/port_characteristics_bm_beta_equity_jtix.png)

* **Investments** The figure below clearly illustrates that during the Great Recession
the investment of most exposed firms were substantially below investments of least
exposed firms and in fact were negative. This provides a partial explanation for why
book-to-market of most exposed firms quickly mean reverts during the Great Recession:
the book part of book-to-market decreases.

![Comparing Investments across most and least exposed firms]({{site.url}}/assets/images/port_characteristics_at_growth_beta_equity_jtix.png)










