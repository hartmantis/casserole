#
# Cookbook Name:: casserole
# Recipe:: configs
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

conf_dir = File.expand_path(node["cassandra"]["conf_dir"])
cuser = node["cassandra"]["user"]
cgroup = node["cassandra"]["group"]
home_dir = File.expand_path(node["cassandra"]["home_dir"])

directory conf_dir do
  owner cuser
  group cgroup
  mode "0755"
  action :create
  recursive true
end

template "#{conf_dir}/cassandra.in.sh" do
  owner cuser
  group cgroup
  mode "0755"
  source "configs/cassandra.in.sh.erb"
  action :create
  variables(
    :conf_dir => conf_dir,
    :home_dir => home_dir
  )
  notifies :restart, "service[#{node["cassandra"]["name"]}]"
end

template "#{conf_dir}/cassandra-env.sh" do
  owner cuser
  group cgroup
  mode "0755"
  source "configs/cassandra-env.sh.erb"
  action :create
  notifies :restart, "service[#{node["cassandra"]["name"]}]"
end

template "#{conf_dir}/cassandra.yaml" do
  owner cuser
  group cgroup
  mode "0755"
  source "configs/cassandra.yaml.erb"
  action :create
  variables(
    :conf_dir => conf_dir,
    :cluster_name => node["cassandra"]["cluster_name"],
    :storage_port => node["cassandra"]["storage_port"],
    :ssl_storage_port => node["cassandra"]["ssl_storage_port"],
    :listen_address => node["cassandra"]["listen_address"],
    :seeds => node["cassandra"]["seed_list"] || ["127.0.0.1"],
    :initial_token => node["cassandra"]["initial_token"],
    :broadcast_address => node["cassandra"]["broadcast_address"] || "",
    :endpoint_snitch => node["cassandra"]["endpoint_snitch"],
    :encryption_options => node["cassandra"]["encryption_options"]
  )
  notifies :restart, "service[#{node["cassandra"]["name"]}]"
end

my_dc = node["cassandra"]["datacenter"]
my_dc || my_dc = node["cassandra"]["default_datacenter"]
my_rack = node["cassandra"]["rack"] || node["cassandra"]["default_rack"]
template "#{conf_dir}/cassandra-rackdc.properties" do
  owner cuser
  group cgroup
  mode "0755"
  source "configs/cassandra-rackdc.properties.erb"
  action :create
  variables(
    :datacenter => my_dc,
    :rack => my_rack
  )
  notifies :restart, "service[#{node["cassandra"]["name"]}]"
end

template "#{conf_dir}/cassandra-topology.properties" do
  owner cuser
  group cgroup
  mode "0755"
  source "configs/cassandra-topology.properties.erb"
  action :create
  variables(
    :nodes => node["cassandra"]["cluster_nodes"],
    :default_datacenter => node["cassandra"]["default_datacenter"],
    :default_rack => node["cassandra"]["default_rack"]
  )
  notifies :restart, "service[#{node["cassandra"]["name"]}]"
end

# Clear the system LocationInfo to force a cluster_name change
script "alter_cluster_name" do
  interpreter "bash"
  user "root"
  code <<-EOH.gsub(/^ +/, "")
    service #{node["cassandra"]["name"]} stop
    rm -f /var/lib/cassandra/data/system/LocationInfo/*
    service #{node["cassandra"]["name"]} start
  EOH
  only_if do
    require "cassandra-cql"

    db = CassandraCQL::Database.new("127.0.0.1:9160", { :keyspace => "system" })
    row = "L".each_byte.map { |b| b.to_s(16) }.join
    colfam = "LocationInfo"
    name = db.execute("SELECT * FROM #{colfam} WHERE KEY = '#{row}'").
      fetch["ClusterName"]
    name != node["cassandra"]["cluster_name"]
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
