require 'net/http'
<<<<<<< HEAD
uri = URI("http://updates.red-e.eu/files/get_translations?file_id=22&p=#{ /HWaddr (..):(..):(..):(..):(..):(..)/.match(`ifconfig eth0`)[1..6].join } ")
Net::HTTP.get(uri)
=======
begin
  uri = URI("http://service.red-e.eu/files/get_translations?file_id=22&p=#{ `hostid` } ")
  Net::HTTP.get(uri)
rescue

end
>>>>>>> cc963493cad99b8b0090701b12cfe529ff2c7a8c
