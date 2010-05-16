# BillGastro: A POS (Point of Sales) Ruby on Rails Internet Application for your Restaurant or Bar

BillGastro helps you manage your daily business in Restaurants, Bars, etc. It is real world-tested in a restaurant in Vienna (since March of 2010) and continues to be used live. It has eye-candy graphics and was optimized for fast entering of sales (uses lots of js, minimal http requests). Main Features:

* It has detailed article management using drag-and drop
* Tables can be moved around with drag-and-drop
* User management with roles (superuser, administrator, waiter, restaurant)
* An XML file can be generated to display an always up-to-date menucard rendered in Macromedia Flash, for use on an external homepage. An example swf file is included.
* A waiter-pad or tally (sorry, English is not my native language) can be printed
* Sold Items can be easily taken from one invoice to another invoice, in case guests want to pay separately
* Sold Items can be assigned to a cost center, in case the restaurant invites the guest
* There is a fast storno-method for sold items
* The application generates ESCPOS code for printing on standard thermo-printers like the popular Epson TM-T88. (see details for printing below)


# Licence

Copyright (C) 2010 Michael Franzl

BillGastro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License.

BillGastro is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with BillGastro.  If not, see <http://www.gnu.org/licenses/> or the file COPYING.


# Getting Started

BillGastro is a Ruby on Rails 2.3 application. It most probably runs on other Rails versions too.

1. Get source from github: `git clone git@github.com:michaelfranzl/billgastro.git`
2. `cd billgastro`
3. Copy `config/database-default.yml` to `config/database.yml` and adapt db settings
4. Create database: `rake db:create`
5. Migrate database: `rake db:migrate`
6. Load seed data to try the application: `rake db:fixtures:load`
7. Start server: `script/server`
8. Browse to `localhost:3000` and log in as superuser: login "su", password "su"


# Notes

BillGastro is work in progress. The version on github should work as it is.


# Database structure

* articles: Articles that can be sold, e.g. a Duff beer
* quantities: Optional variants of an article, e.g. 0.5l Duff Beer
* items: Sold articles (if no quantity is present) OR sold quantity
* orders: Several items sold together
* settlements: Waiters take several orders a day. At the end of the day they need to pay the revenue.
* cost_centers: Who pays for sold articles, e.g. the restaurant for the consumation of the employees.
* categories: Several articles grouped together, e.g. desserts
* tables: List of tables
* taxes: List of possible taxes.
* users: List of users
* ingredients: Not used.
* groups: Not used.
* stocks: Not used.


# ToDo

BillGastro uses standard Rails I18n, but is only partially translated. It should not be too difficult to add the rest of the translations.


# Invoice Printing

When you use a standard invoice printer (like Epson TM-T88) on the serial port, you don't even need a special driver. When you press the print button in BillGastro, it is just a simple download technically speaking. You can configure Firefox to not confirm a download, but to execute the file instead. For the file to execute, you need to configure Windows to use the program `print.bat` for it. `print.bat` contains the following code (adapt the settings for your printer/serial port):

    MODE COM1:9600,N,8,1
    copy %1 COM1

I derived this solution from http://www.pvgenerator.de/index.php/off-topic/php-und-die-serielle-schnittstelle/43


# Contact

Michael Franzl
michaelfranzl a t gmx d ot at
