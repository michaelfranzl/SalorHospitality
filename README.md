SALOR Hospitality (aka. Bill Gastro)
====================================

The modern, enterprise-class Point of Sale (POS) Solution serving the Hospitality Industry: Hotels, Restaurants, Inns, Bars and Shops.


Important Notice
------------------------

This project is no longer actively developed or supported. The last stable tag is `debian/4.1.4.97`.


Development Installation
------------------------

The following instructions are based on plain Debian Wheezy, and will use its Ruby interpreter 1.9.3.

You need a few system packages so that native extensions of ruby gems will compile successfully:

    apt-get install mysql-server mysql-client libmysqlclient-dev imagemagick libmagick-dev libmagickwand-dev

Any Rails developer will not have any problems running Salor Hospitality, since it is just a plain, standalone Rails application without any special magic going on.

    git clone git://github.com/michaelfranzl/SalorHospitality.git
    cd SalorHospitality/salor-hospitality
    cd config
    cp database.yml.default database.yml

At this point, change `database.yml` for your database installation.

    cd ..
    bundle install
    rake db:create
    rake db:migrate
    rake db:seed
    rails s

At this point, the app is running. You can browse to http://localhost:3000 and enter 000 as password.

If you want to re-seed the database do the following:

    rake db:drop
    rake db:create
    rake db:migrate
    rake db:seed
    
    
    
License
------------------------

Copyright © 2015 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.