#!/usr/bin/ruby

# Script to show current katello developer happiness with gifs

box_name = "centos7-devel"
forklift_location="/home/jomitsch/sat-deploy/forklift"
dir_location="/var/www/html/"
webpage = File.join(dir_location, "index.html")
current_date = Time.now

Dir.chdir(forklift_location) do |dir|
  `git fetch --all`
  `git reset --hard origin/master`
  `cp vagrant/boxes.d/99-local.yaml.example vagrant/boxes.d/99-local.yaml`
  `vagrant destroy -f #{box_name}`
  `vagrant up #{box_name} &> #{dir_location}/console.out`
end

if $?.success?
  `cp -f success.html #{webpage}`
else
  `cp -f failure.html #{webpage}`
end

Dir.chdir(forklift_location) do |dir|
  `vagrant destroy -f #{box_name}`
end

`echo \"Ran on #{current_date}\" >> #{webpage}`
