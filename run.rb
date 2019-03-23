#!/usr/bin/ruby
require "fileutils"

# Script to show current katello developer happiness with gifs

box_name = "centos7-katello-devel"
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

  if $?.success?
    puts "success"
    FileUtils.cp(File.join(script_location, "success.html"), webpage_location)

    # Create stable image
    stable_box_image = 'centos7-katello-devel-stable.box'
    `vagrant package centos7-katello-devel --output #{stable_box_image}`
    hosted_image_dir = "#{apache_location}pub/devbox"
    `cp -f #{forklift_location}/#{stable_box_image} #{hosted_image_dir}`
    `cp -f #{forklift_location}/.vagrant/machines/#{box_name}/libvirt/private_key #{hosted_image_dir}`  
    `chmod 644 #{hosted_image_dir}/private_key`
  else
    puts "failure"
    FileUtils.cp(File.join(script_location, "failure.html"), webpage_location)
  end
end

FileUtils.cp("/tmp/console.out", File.join(apache_location, "console.out"))

Dir.chdir(forklift_location) do |dir|
  `vagrant destroy -f #{box_name}`
end

`echo \"Ran on #{current_date}\" >> #{webpage_location}`
