#!/usr/bin/ruby
require "fileutils"

# Script to show current katello developer happiness with gifs

box_name = "centos7-devel"
command = "vagrant up #{box_name}"
forklift_location="/home/jomitsch/sat-deploy/forklift"
boxes_location = File.join(forklift_location, "vagrant/boxes.d/")
apache_location="/var/www/html/"
webpage_location = File.join(apache_location, "index.html")
script_location = "/home/jomitsch/test-katello-devel-box"
current_date = Time.now

FileUtils.rm("/tmp/console.out")

Dir.chdir(forklift_location) do |dir|
  `git fetch --all`
  `git reset --hard origin/master`
   FileUtils.cp(File.join(boxes_location, "99-local.yaml.example"), 
		File.join(boxes_location, "99-local.yaml"))
  `vagrant destroy -f #{box_name}`
  `#{command} &> /tmp/console.out`
end

if $?.success?
  puts "success"
  FileUtils.cp(File.join(script_location, "success.html"), webpage_location)
else
  puts "failure"
  FileUtils.cp(File.join(script_location, "failure.html"), webpage_location)
end

FileUtils.cp("/tmp/console.out", File.join(apache_location, "console.out"))

Dir.chdir(forklift_location) do |dir|
  `vagrant destroy -f #{box_name}`
end

`echo \"Ran on #{current_date}\" >> #{webpage_location}`
