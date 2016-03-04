#
# Cookbook Name:: hpe-cookbook
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#
require 'chef/provisioning/aws_driver'
require 'fileutils'

with_driver 'aws'

num_webservers = 1

with_machine_options({
  convergence_options: {
	    ssl_verify_mode: :verify_peer,
	    allow_overwrite_keys: true,
	    client_rb_path: "/etc/chef/client.rb",
	    chef_server: "https://ip-172-31-19-13.eu-central-1.compute.internal/organizations/4thcoffe",
  },
  bootstrap_options: {
  	key_name: "hpe-cluster1",
	},
  ssh_username: "ec2-user",
})

1.upto(num_webservers) do |i|
	file_name = "/home/ec2-user/testmachine-#{i}.rb"
	FileUtils.cp 'home/ec2-user/client.rb', file_name
	text = File.read(file_name)
 	new_contents = text.gsub(/newmachine/, "testmachine-#{i}")
	File.open(file_name, "w") {|file| file.puts new_contents}
end

machine_batch do
	1.upto(num_webservers) do |i|

		machine "testmachine-#{i}" do
		  action :converge
		  recipe 'htop'
		  recipe 'nginx'
		  recipe 'jboss7'
		  driver 'aws'
		  files '/etc/chef/client.rb' => "/home/ec2-user/testmachine-#{i}.rb",
			'/etc/chef/trusted_certs/ip-172-31-19-13.eu-central-1.compute.internal.crt' => '/etc/chef/trusted_certs/ip-172-31-19-13.eu-central-1.compute.internal.crt'
		  chef_environment 'hpe-demo-for-client'
		  chef_server :chef_server_url=>"https://ip-172-31-19-13.eu-central-1.compute.internal/organizations/4thcoffe",
			:options=>{:signing_key_filename=>"/home/ec2-user/.chef/zabkiewi.pem",
			:client_name=>"zabkiewi"}
		  from_image 'ami-cd362ca1'
		  tag 'test-provisioning'
		end
	end
end

