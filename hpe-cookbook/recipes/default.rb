#
# Cookbook Name:: hpe-cookbook
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#
require 'chef/provisioning'

num_webservers = 2

machine_batch do
	1.upto(num_webservers) do |i|
	  machine "luigi#{i}" do
	   recipe 'htop'
	   recipe 'nginx'
	   tag 'test_provisioning'
	  end
	end
end

