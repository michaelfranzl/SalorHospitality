SALOR Hospitality
=================

The innovative Point of Sale Solution serving the Hospitality Industry

This document was updated on: July 15 2012

History
-------

This software product has been in continuous development and used in real-world settings since beginning of 2009. Red (E) Tools Ltd. (http://red-e.eu) is pleased to make it finally available publicly under the MIT License. This product was formerly known as BillGastro (http://billgastro.com), but after the addition of features for Hotels and many new improvements in 2012, it was renamed to "SALOR Hospitality" to reflect it's closeness to the hospitality industry as a whole. From launch of concept to full operation, SALOR Hospitality was developed with real-time input from waiters and kitchen personnel in successful, high-pressure environments.

"SALOR Hospitality" is part of the SALOR software family. Its sister, "SALOR Retail" is a pure Javascript offline application aimed at serving supermarkets and retail stores, currently in development. Its new and unique architectural design -- zero dependency on any web framework -- was inspired by our rather painful real-life experiences of what actually works -- and what doesn't -- in the world of web application development. "SALOR Retail" is available at https://github.com/jasonknight/salor .

Overview
--------

"SALOR Hospitality" revolutionizes the day to day operation of the Hospitality Industry, bringing businesses large and small into the 21st century. We believe the time has come to integrate smart technology with customer service, taking both to a new level. "SALOR Hospitality" provides insight into every aspect of your daily operations and business across multiple metrics, allowing you to plan performance improvements.

**Cutting edge design:**
  Appealing design with clean lines and colour schemes for table and staff differentiation, product categories, etc. SalorHospitality looks great on any system!

**Flexibility:**
  Productive work relationships are the cornerstone of any successful business. SalorHospitality allows you to better coordinate work schedules and responsibilities between staff.

**Efficiency:**
  SalorHospitality helps you deliver prompt and friendly service to your customers. It is clear, easy and safe to use, optimising workflow from the back office to the kitchen to the restaurant floor.

**Extensibility:**
  As your business grows, SalorHospitality will grow with you. Its unique system design facilitates seamless enhancements to existing functionality.

**Versatility:**
  Adapt SalorHospitality to your business by reorganising the table polan, introducing new menus, adding new products and services.

**Accessibility:**
  Remote access gives you the freedom to run your business anytime from anywhere.

**Virtual Restaurant/Hotel:**
  SalorHospitality can extend your restaurant or hotel to your customers' homes. They just take orders online or reserve tables, notifying staff who can prepare in advance.

**Multi-Functionality:**
  The software multifunctional, allowing you to monitor, export and print customized accounts, statistics and tax reports, update your wholesalers' price lists, easily split receipts, generate professional invoices, and much more.
  
**International:**
  SALOR Hospitality has been translated into 8 languages so far (2012): English, German, French, Spanish, Greek, Russian, Polish, Chinese. Additional languages are currently in the process of translation.

**Compatibility:**
  "SALOR Hospitality" will run in the browser of any computer and mobile device like Smartphones, so you needn't buy any special devices. However, Red (E) Ltd. can suggest and source hardware optimized for SalorHospitality -- touchscreens, thermal printers, handhelds or tablets.

Many more interestig features:

* Dynamic search function for product database
* Tickets for kitchen and bar
* Instant messaging between all staff
* Immediate updates between all terminals in use
* Enter special customer requests directly at the table -- also in handwriting!
* Compatible with tax schemes in several countries
* Multiple thermal printers
* and much more


Features
--------

For a quick demonstration of a small part of all features, watch the screencasts that are available on youtube:

http://www.youtube.com/watch?v=SUfm17WYRdA (Restaurant only)

Documentation
-------------

Software documentation will be online soon. Work in progress!

Philosophy of technology
------------------------

The applications consists of a lean Ruby-on-Rails backend (Ruby 1.9.3 and Rails 3.2.6) with a MySQL database which is responsible for delivering and storing of data, controlling all attached printers, whereas the the actual Point of Sale interface is entirely controlled by offline Javascript and an offline database. This concept unites the advantages of networking between many handhelds in one store (or many stores of a restaurant/hotel chain) with an amazing responsiveness of the user interface (UI). Because all Javascript and data are residing in the RAM of the browser, a steady connection to the server is not even required. The Javascript application communicates its data via small JSON objects, which only a few dozen bytes per taking an order. If the server cannot be reached, the data are stored in a queue and can be re-sent once the connection is established again.

Because SALOR Hospitality is based on standard web technologies, it can immediately be used with a wide variety of standard hardware or Operating Systems without hassle: Windows, Linux, OS X, PC's, MAC's, desktops, laptops, handhelds, tablets and smartphones. Just fire up your browser and enter the the URL of your SALOR server. SALOR can distinguish between large and small screens and delivers styles accordingly.

Maturity
--------

Many hospitality enterprises -- usually high-stress and high-pressure environments -- already enjoy the use of SALOR Hospitality. They have contributed feedback to make SALOR the excellent product it is today.

Multi-Store, Multi-Company
--------------------------

SALOR Hospitality has true multi-store (and even multi-company) support built in. That way, you deploy once, and serve many of your stores at once.


Try it live!
------------

You can try SALOR Hospitality immediately. Install Google Chrome, Chromium or Safari (or any browser based on Webkit), browse to [sh.red-e.eu](http://sh.red-e.eu) (will be set up soon) and log in with one of the following passwords:

Hint: After you've logged in, you can click on the client logo on the top left of the screen. This opens up the admin menu and enables drag and drop of the tables. When the admin menu is closed, table dragging is disabled.

Warning: The database of the online demo resets itself frequently. Do not expect your added content to persist.


Give back!
----------

We have spent hundreds, if not thousands of hours in making this product available to you, for free. If you feel that our product has benefited you, you can support further developments by donating to our Open Source projects: http://red-e.eu (donation buttons will be set up soon).


Professional Support and Consulting
-----------------------------------

Our company Red (E) Tools Ltd. has a large and growing network of satisfied customers. We provide excellent customer support and consulting for all of our products. We will visit your premises and help you set up your infrastructure. We don't just want you to use our products, we want you to become part of the growing network and share our vision of how awesome the future of your business can be! Contact us today! http://red-e.eu ! (contact form will be set up soon)

Contact
-------

Michael Franzl (https://github.com/michaelfranzl)

Jason Knight (https://github.com/jasonknight)

Red (E) Tools Ltd.

office@red-e.eu
