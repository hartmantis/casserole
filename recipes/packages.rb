#
# Cookbook Name:: casserole
# Recipe:: packages
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

service node["cassandra"]["name"]

node["cassandra"]["packages"].each do |pkg, attrs|
  package pkg do
    action :install
    version attrs["version"] if attrs["version"]
  end
end

node["cassandra"]["chef_gems"].each do |pkg, attrs|
  chef_gem pkg do
    action :install
    version attrs["version"] if attrs["version"]
  end
end

# Some distributed packages of Cassandra start the service in their
# postinstall; keep them all equal and a restart can be done after the configs
# are written on the first run. Added difficulty: they also come with init
# scripts that always exit 0.
script "force_start_cassandra" do
  interpreter "bash"
  user "root"
  code <<-EOH.gsub(/^ +/, "")
    /etc/init.d/#{node["cassandra"]["name"]} start
    for i in `seq 1 20`; do
      echo > /dev/tcp/localhost/9160
      [ $? = 0 ] && exit 0
      sleep 0.5
    done
    exit 1
  EOH
  action :run
  only_if { !File.exist?("#{node["cassandra"]["home_dir"]}/chef_install.log") }
end

directory File.dirname(node["cassandra"]["pid_file"]) do
  owner node["cassandra"]["user"]
  group node["cassandra"]["group"]
  mode "0755"
  action :create
  recursive true
  only_if { File.dirname(node["cassandra"]["pid_file"]) != "/var/run" }
end

template "/etc/init.d/#{node["cassandra"]["name"]}" do
  owner "root"
  group "root"
  mode "0755"
  source "configs/cassandra.init.#{node["platform_family"]}.erb"
  variables(
    :service_name => node["cassandra"]["name"],
    :home_dir => node["cassandra"]["home_dir"],
    :conf_dir => node["cassandra"]["conf_dir"],
    :pid_file => node["cassandra"]["pid_file"],
    :user => node["cassandra"]["user"]
  )
  notifies :restart, "service[#{node["cassandra"]["name"]}]"
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
