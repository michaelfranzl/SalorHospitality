# SALOR Hospitality (aka. Bill Gastro)

The modern, enterprise-class Point of Sale (POS) Solution serving the Hospitality Industry: Hotels, Restaurants, Inns, Bars and Shops.


## Important Notices

This project is now archived after almost two decades after its start in early 2009. As original architect and practically only software developer, I feel obliged to offer one important reflection on the code.

This project was a rapidly created prototype that, following customer's demand, developed into a flagship solution for my garage-type, one-man, software start-up of 2009.

However, there was and still is one critical flaw hiding right at the core of the software that makes the software potentially unsafe to use: money data is stored in the database with a data type of float -- not, as it should be, integer.

This directly came from the fact that I was not trained in Computer Science and lacked critical experience in software development. I lacked foundational knowledge, for example about [Machine epsilon](https://en.wikipedia.org/wiki/Machine_epsilon), that would have helped me to recognize potential consequences coming from this issue.

When a money value was processed in the application, both before and after storing it in the database, Ruby's `Float#round` method was used.
However, even rounding can expose machine epsilon.
While in practice rounding errors from expected sums may be single cents, there still might be higher cost associated with answering corresponding questions about those errors.

To my defense, Ruby's [money](https://rubygems.org/gems/money) gem was created only about 4 months before I started this project, and it also just [used](https://github.com/RubyMoney/money/blob/46762f8ea06119abbea84c1e8e11f3fecb710e12/lib/money/money.rb#L75) Ruby's `Float#round` method, which, by the way, is [inconsistent with](https://bugs.ruby-lang.org/issues/12548) Ruby's `sprintf` method, and which [almost](https://bugs.ruby-lang.org/issues/12958) got changed 10 years later.

This application's rounding algorithm should have been explicitly coded and tested, perhaps being made configurable, and the database should have stored integers instead of floats. These mistakes were architectural and therefore too expensive to fix.

**For the above reasons, I strongly discourage to use this software.**

Consequently, I removed all refs (branches and tags) and the rest of this file, and archived this repository on GitHub, as it no longer serves any constructive purpose.
