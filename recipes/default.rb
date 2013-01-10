#
# Cookbook Name:: casserole
# Recipe:: default
#
# Copyright 2012, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "java"
include_recipe "#{@cookbook_name}::user"
include_recipe "#{@cookbook_name}::repos"
include_recipe "#{@cookbook_name}::packages"
if node["cassandra"]["clustered"] and node["cassandra"]["data_bag"]
  include_recipe "#{@cookbook_name}::data_bag_parser"
end
if node["cassandra"]["encryption_options"]["internode_encryption"] != "none"
  include_recipe "#{@cookbook_name}::encryption"
end
if node["cassandra"]["clustered"] and !node["cassandra"]["initial_token"]
  include_recipe "#{@cookbook_name}::token_generator"
end
include_recipe "#{@cookbook_name}::configs"

([node["cassandra"]["name"]] + node["cassandra"]["extra_services"]).each do |s|
  service s do
    supports :restart => true, :status => true
    action [:enable, :start]
  end
end

file "#{node["cassandra"]["home_dir"]}/chef_install.log" do
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "First run completed #{Time.new}. Do NOT remove this file."
  only_if { !File.exist?("#{node["cassandra"]["home_dir"]}/chef_install.log") }
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
