SALOR Hospitality (aka. Bill Gastro)
====================================

The modern, enterprise-class Point of Sale (POS) Solution serving the Hospitality Industry: Hotels, Restaurants, Inns, Bars and Shops.

Product webpage with all information: [http://billgastro.com](http://billgastro.com)



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