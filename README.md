SALOR Hospitality
=================

The innovative Point of Sale Solution serving the Hospitality Industry

This document was updated on: December 20, 2012

History
-------

This software product has been in continuous development and used in real-world settings since beginning of 2009. Red (E) Tools Ltd. (http://red-e.eu) is pleased to make it finally available publicly under the MIT License. This product was formerly known as BillGastro (http://billgastro.com), but after the addition of features for Hotels and many new improvements in 2012, it was renamed to "SALOR Hospitality" to reflect it's closeness to the hospitality industry as a whole. From launch of concept to full operation, SALOR Hospitality was developed with real-time input from waiters and kitchen personnel in successful, high-pressure environments.

"SALOR Hospitality" is part of the SALOR software family and is aimed at Restaurants, Bars, Hotels, food stores, etc. Its sister, "SALOR Retail" is aimed at Retail stores, supermarkets, industries, etc. It is available at https://github.com/jasonknight/salor-retail

"SALOR Retail" is currently being re-written as a pure Javascript offline application. Its new and unique architectural design -- zero dependency on any web framework -- was inspired by our rather painful real-life experiences of what actually works in the world of web application development, and what doesn't. This project is available at https://github.com/jasonknight/salor .

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

For a quick demonstration of a small part of the features (the Restaurant part), watch the screencasts that are available on Youtube:

http://www.youtube.com/watch?v=SUfm17WYRdA (This video covers restaurant functions only)

Documentation
-------------

Software documentation is work in progress!

http://documentation.red-e.eu

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

Installation
------------

You need a few packages so that native extensions of ruby gems will compile successfully:

    apt-get install mysql-server mysql-client libmysqlclient-dev imagemagick libmagick-dev libmagickwand-dev

Depending on your Linux Distribution, you also must install the Ruby interpreter of the version family 1.9 (we work with ruby-1.9.3.194), either via `apt-get install ruby1.9.1` or a Ruby Version Manager like `rvm`.

Any Rails developer will not have any problems running SalorHospitality, since it is just a plain Rails project without any special magic going on:

    git clone git://github.com/michaelfranzl/SalorHospitality.git
    cd SalorHospitality/salor-hospitality
    bundle install
    {{ edit config/database.yml for your MySQL installation }}
    rake db:create
    rake db:migrate
    rake db:seed
    rails s
    {{ browse to localhost:3000 and enter 000 as password }}
    
For installation on a production system, Red (E) Tools Ltd. also provides pre-compiled Debian packages for several Linux distributions (Debian Wheezy, Ubuntu 10.04, Ubuntu 10.10, Ubuntu 12.04 LTS, Ubuntu 12.10) that make the installation a breeze! Have a look at the installation instructions at http://documentation.red-e.eu/installation/index.html

Try it live!
------------

You can try SALOR Hospitality immediately. Install Google Chrome, Chromium or Safari (or any browser based on Webkit), browse to [demo1.sh.red-e.eu](http://demo1.sh.red-e.eu) and log in with the default password 000 (zero-zero-zero).

Support for Mozilla Firefox is limited to the Restaurant part. The Hotel part makes use of a browser-internal SQL database, which is not supported in Firefox. We never really tested Microsoft Internet Explorer, so you are on your own if you want to use this browser.


Get Support!
------------

Our company Red (E) Tools Ltd. has a large and growing network of satisfied customers. It's software products all are in production stage since years. We provide excellent customer support and consulting for all of our products. We will visit your premises and help you set up your infrastructure. We don't just want you to use our products, we want you to become part of the growing network and share our vision of how awesome the future of your business can be!

If you find Bugs or want to request new features, please subscribe and use our Redmine bugtracking system: 

http://redmine.red-e.eu

If you want to ask questions or get general support, please subscribe to our mailing list: [salor-hospitality-users@googlegroups.com](https://groups.google.com/forum/?fromgroups#!forum/salor-hospitality-users)

For other inquiries, please contact us via the contact form on our website: http://red-e.eu ! (contact form will be set up soon)

Give back!
----------

We have spent hundreds, if not thousands of hours in making this product available to you, for free. If you feel that our product has benefited you, you can support further developments by donating to our Open Source projects: http://red-e.eu (donation buttons will be set up soon).

If you can't give money right now, sign up to Twitter, "follow" us and post about your experience: [http://twitter.com/RedETools](twitter.com/RedETools)

Contact
-------

Michael Franzl (https://github.com/michaelfranzl)

Jason Knight (https://github.com/jasonknight)

Red (E) Tools Ltd.

office@red-e.eu
