
SALOR Hospitality
=================

The modern, enterprise-class Point of Sale Solution serving the Hospitality Industry

This document was updated on: October 26, 2014

About
-----

SALOR Hospitality (also known as Bill Gastro) is a professional, universal, complete, enterprise-class Point of Sale software for single hotels, hotel chains, single restaurants, restaurant chains, bars and snack shops.

If you install SALOR Hospitality on a computer (e.g. a regular mini PC), and connect thermal receipt printers, touch screens and a wireless Bridge, you will end up with much more than a regular Point of Sale system. Depending on your needs, you can expand it to have **your own management system for your hospitality business** which you can access conveniently from any computer or mobile device (e.g. smartphone or tablet) which is connected to the internal ethernet/wireless network of your company.

Because you can extend the installation to your heart's content, SALOR Hospitality helps you to **improve the communication between staff in your business**, and you will be able to serve your customers much quicker.

SALOR Hospitality sends tickets to the thermal printers installed in your kitchen or bar and makes printing of professional business invoices and the generation of financial and statistics reports very easy. This simplifies your accounting work to an extreme degree and you can **dedicate more time for more important things**: the personal contact with your customers.

SALOR Hospitality has many more useful features that are not yet documented in writing (we're working on that!), but it is better nevertheless if you test the software yourself immediately with our public demo ([see this page for details][http://billgastro.com/test.html]).

Read about the extraordinarily good mobile support [here](http://billgastro.com/about.html).


History
-------

This software product has been in continuous development and used in real-world settings since beginning of 2009. Red (E) Tools Ltd. (http://thebigrede.net) is pleased to make it finally available publicly under the very permissive MIT License. This product was formerly known as "Bill Gastro" (http://billgastro.com), but after the addition of features for Hotels and many new improvements in 2012, it was renamed to "SALOR Hospitality" to reflect it's closeness to the hospitality industry as a whole. From launch of concept to full operation, SALOR Hospitality was developed with real-time input from waiters, kitchen personnel and store owners in successful, high-pressure environments.

"SALOR Hospitality" is part of the SALOR software family and is aimed at Restaurants, Bars, Hotels, food stores, etc. Its sister, "SALOR Retail" is aimed at retail stores, supermarkets, industries, etc. Have a look at https://github.com/jasonknight/salor-retail

Overview
--------

"SALOR Hospitality" revolutionizes the day to day operations of the Hospitality Industry, bringing businesses large and small into the 21st century. We believe the time has come to integrate smart technology with customer service, taking both to a new level. "SALOR Hospitality" provides insight into every aspect of your daily operations and business across multiple metrics, allowing you to plan performance improvements.

**Essential features:**
  You won't miss any essential feature that other, similar Point of Sale software has!

**Cutting-edge design:**
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
  SALOR Hospitality has been translated into 11 languages so far (2013): English, German, French, Spanish, Greek, Russian, Polish, Chinese, Dutch, Finnish, Croatian. Additional languages are currently in the process of translation.

**Compatibility:**
  "SALOR Hospitality" will run in the browser of any computer and mobile device like Smartphones, so you needn't buy any special devices. However, Red (E) Ltd. can suggest and source hardware optimized for SalorHospitality -- touchscreens, thermal printers, handhelds or tablets.

Many more interestig features:

* Dynamic search function for product database
* Prints tickets on thermal printers for kitchen and bar
* Immediate status updates between all terminals in use -- no synchronization needed!
* Enter special customer requests directly at the table -- also in handwriting!
* Compatible with tax schemes in several countries
* Multiple thermal printers with different interfaces: USB, RS232, TCP/IP (Ethernet and Wireless)
* and much more


Features
--------

For a quick demonstration of a small part of the features (the Restaurant part), watch the screencasts that are available on Youtube:

http://www.youtube.com/watch?v=SUfm17WYRdA (This video covers restaurant functions only)

More videos are planned, but haven't been made yet.


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


Try the Demo!
------------

You can try SALOR Hospitality immediately. Install Google Chrome, Chromium or Safari (or any browser based on Webkit), then ([see this page for details about how to access the public demo][http://billgastro.com/test.html]).

Support for Mozilla Firefox is limited to the restaurant part. The hotel part makes use of a browser-internal SQL database, which is not supported in Firefox. Microsoft Internet Explorer is not supported.


Installation
------------

You need a few packages so that native extensions of ruby gems will compile successfully (these instructions are based on Debian Wheezy):

    apt-get install mysql-server mysql-client libmysqlclient-dev imagemagick libmagick-dev libmagickwand-dev

Depending on your Linux Distribution, you also must install the Ruby interpreter of the version family 1.9 (we work with ruby-1.9.3.194), either via `apt-get install ruby1.9.1` or a Ruby Version Manager like `rvm`.

Any Rails developer will not have any problems running SalorHospitality, since it is just a plain Rails project without any special magic going on:

    git clone git://github.com/michaelfranzl/SalorHospitality.git
    cd SalorHospitality/salor-hospitality
    cp Gemfile.production Gemfile
    {{ or use Gemfile.development if appropriate }}
    cd config
    cp database.yml.template database.yml
    cd ..
    bundle install
    {{ edit config/database.yml for your MySQL installation }}
    rake db:create
    rake db:migrate
    rake db:seed
    rails s
    {{ browse to localhost:3000 and enter 000 as password }}

If you want to re-seed the database do the following:

    rake db:drop
    rake db:create
    rake db:migrate
    rake db:seed
    
For installation on a production system, Red (E) Tools Ltd. also provides pre-compiled Debian packages for several Linux distributions. Have a look at the installation instructions at http://documentation.thebigrede.net/hospitality/installation.html


Documentation
-------------

Visit the product website at

http://billgastro.com

Software documentation is work in progress:

http://documentation.thebigrede.net/hospitality

In-depth information can be found in our support forum:

http://forum.thebigrede.net


Get Support!
------------

Our company Red (E) Tools Ltd. has a large and growing network of satisfied customers. Our software products all are in production stage since several years, and are used around the globe, continuously around the clock. We provide excellent customer support and consulting for all of our products. We will visit your premises and help you set up your infrastructure. We don't just want you to use our products, we want you to become part of the growing network and share our vision of how awesome the future of your business can be!

If you find bugs or want to request new features, please use the issue tracker of the github repository at https://github.com/michaelfranzl/SalorHospitality

If you want to ask questions or get general support, please use our forum http://forum.thebigrede.net. We will reply to you personally reliably.


Buy a monthly subscription for your managed, personal online account
--------------------------------------------------------------------

Visit http://shop.thebigrede.net/cart/products/1



Give back!
----------

Red (E) Tools Ltd. is pleased to make its main products available to you, for free. We believe in Open Source in the fullest sense of the word, which is the reason why we have added the very permissive MIT License to our products, allowing you to use them for free -- yes, free as in "free beer".

We invite developers to download SALOR Hospitality, enhance it and publish the enhancements in return. This guarantees that the software will grow and continue to be there for hospitality businesses large and small.

Since 2009, the founders of Red (E) Tools Ltd. have literally spent thousands of hours in front of the computer and with clients to forge SALOR Hospitality into a production-ready, world-class software product.

However, nothing is really for free, so we ask you give something back if you feel that our products have benefited you. Recommend SALOR Hospitality to your friends and business contacts!

You can help us in the following way:

* Use Twitter, 'follow' our [Twitter profile](https://twitter.com/RedETools) and post about us.
* Use Facebook, “like” our Facebook pages for [Red E](http://www.facebook.com/pages/Red-E-Tools-Ltd/355936374462066) and [Salor Hospitality](https://plus.google.com/u/0/b/109404068814152227625/109404068814152227625/posts) and share them.
* Use GooglePlus, and “+1″ our pages for [Red E](https://plus.google.com/b/101223278745291442261/101223278745291442261/posts), [Salor Hospitality](https://plus.google.com/u/0/b/109404068814152227625/109404068814152227625/posts) and share them.
* Use GitHub and “star”, download or “watch” the sources of [SALOR Hospitality](https://github.com/michaelfranzl/SalorHospitality)
* Promote our [XING Company Profile](https://www.xing.com/companies/redetools).


Contact
-------

Michael Franzl (https://github.com/michaelfranzl)

Jason Knight (https://github.com/jasonknight)

Red (E) Tools Ltd.

office@thebigrede.net
