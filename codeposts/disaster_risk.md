---
layout: default
title: Disaster Risk
---

## Disaster Risk

Code can be found on [Github](https://github.com/rsigalov/disaster-risk-revision).

The code generates disaster measure introduced in [Siriwardane (2015)](https://www.hbs.edu/faculty/Publication%20Files/16-061_797fe134-9faa-4a5f-be41-1f1e5bebddcb.pdf). To do it
the code loads data on individual names options, fits SVI smiles into implied
volatilities and isolates the jump component following
[Du and Kapadia (2012)](https://people.umass.edu/nkapadia/docs/Du_Kapadia_August2012.pdf).
Prior research (e.g. ...) found that small companies are
more correlated with real economic activity. A disaster measure constructed from
individual names rather than using options of aggregate indices highlights this
distinction.

Below I show the disaster measure and contribution of different sectors. In
particular, elevated disaster measure during the DotCom bubble is driven
primarily by *Business Equipment* industry (tech) and in the GFC by *Money*
industry (banks and insurance companies).
![Disaster Risk]({{site.url}}/assets/images/disaster_risk.png)
