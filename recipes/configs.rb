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
#     http://www.apache.org/licenses/LICENSE-2.0
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
chome = File.expand_path(node["cassandra"]["home_dir"])

if node["cassandra"]["clustered"]
    cluster_conf = data_bag_item(node["cassandra"]["data_bag"],
        node["cassandra"]["cluster_name"])

    node_conf = cluster_conf["nodes"].collect {|n| n if
        n["id"] == node["cassandra"]["node_id"]}.compact[0]

    seed_list = cluster_conf["nodes"].collect {|n| n["broadcast_address"] if
        n["seed"]}.compact.sort

    # Token = (2**127 / num_nodes_in_dc * n + DC_ID)
    dc_list = cluster_conf["nodes"].collect {|n| n["datacenter"]}.uniq.sort
    token_offset = dc_list.index(node_conf["datacenter"]) * 100
    dc_nodes = cluster_conf["nodes"].collect {|n| n["id"] if
        n["datacenter"] == node_conf["datacenter"]}.compact.sort
    node_count = dc_nodes.length
    node_pos = dc_nodes.index(node["cassandra"]["node_id"]) + 1
    initial_token = 2**127 / node_count * node_pos + token_offset

    endpoint_snitch = cluster_conf["endpoint_snitch"]
else
    seed_list = ["127.0.0.1"]
    initial_token = ""
    node_conf = {
        "broadcast_address" => "",
        "datacenter" => "DC1",
        "rack" => "RAC1"
    }
    cluster_conf = {
        "nodes" => [],
        "endpoint_snitch" => "SimpleSnitch"
    }
end

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
        :home_dir => chome
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
        :cluster_name => node["cassandra"]["cluster_name"],
        :listen_address => node["cassandra"]["listen_address"],
        :seeds => seed_list,
        :initial_token => initial_token,
        :broadcast_address => node_conf["broadcast_address"],
        :endpoint_snitch => cluster_conf["endpoint_snitch"]
    )
    notifies :restart, "service[#{node["cassandra"]["name"]}]"
end

template "#{conf_dir}/cassandra-rackdc.properties" do
    owner cuser
    group cgroup
    mode "0755"
    source "configs/cassandra-rackdc.properties.erb"
    action :create
    variables(
        :datacenter => node_conf["datacenter"],
        :rack => node_conf["rack"]
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
        :nodes => cluster_conf["nodes"],
        :default_datacenter => "DC1",
        :default_rack => "RAC1"
    )
    notifies :restart, "service[#{node["cassandra"]["name"]}]"
end

# vim:et:fdm=marker:sts=4:sw=4:ts=4:
