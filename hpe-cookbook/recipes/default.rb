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

fqdn = "ip-172-31-16-47.eu-central-1.compute.internal"
num_webservers = 2

with_machine_options({
  convergence_options: {
	    ssl_verify_mode: :verify_peer,
	    allow_overwrite_keys: true,
	    client_rb_path: "/etc/chef/client.rb",
	    chef_server: "https://#{fqdn}/organizations/4thcoffe",
  },
  bootstrap_options: {
  	key_name: "hpe-cluster1",
	},
  ssh_username: "ec2-user",
})

1.upto(num_webservers) do |i|
	file_name = "/tmp/testmachine-#{i}.rb"
	FileUtils.cp '/etc/chef/jenkins_run/client.rb', file_name
	text = File.read(file_name)
 	new_contents = text.gsub(/newmachine/, "testmachine-#{i}")
	File.open(file_name, "w") {|file| file.puts new_contents}

file "/tmp/testmachine-#{i}.rb" do
  mode '0666'
end
end


machine_batch do
	1.upto(num_webservers) do |i|

		machine "testmachine-#{i}" do
		  action :converge
		  role 'demo-role'
		  driver 'aws'
		  files '/etc/chef/client.rb' => "/tmp/testmachine-#{i}.rb",
			"/etc/chef/trusted_certs/#{fqdn}.crt" => "/etc/chef/trusted_certs/#{fqdn}.crt"
		  chef_environment 'hpe-demo-for-client'
		  chef_server :chef_server_url=>"https://#{fqdn}/organizations/4thcoffe",
			:options=>{:signing_key_filename=>"/tmp/zabkiewi.pem",
			:client_name=>"zabkiewi"}
		  from_image 'ami-cd362ca1'
		  tag 'test-provisioning'
		end
	end
end

