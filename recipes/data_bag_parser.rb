#
# Cookbook Name:: casserole
# Recipe:: data_bag_parser
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

# Combine data bag settings with ones provided in the attributes phase
# to create a full attribute set for this node.

cluster_conf = data_bag_item(node["cassandra"]["data_bag"],
  node["cassandra"]["cluster_name"])
node.default["cassandra"]["cluster_nodes"] = cluster_conf["nodes"]

# Extract the information about the node from the cluster
node_conf = cluster_conf["nodes"][node["cassandra"]["node_id"]]
if !node_conf
  raise Chef::Exceptions::ConfigurationError,
    "Node was not defined in the cluster config"
end

# Allow data bag entries to take precedence over default attributes
%w{listen_address broadcast_address datacenter rack}.each do |a|
  if node_conf[a] then node.default["cassandra"][a] = node_conf[a] end
end
%w{endpoint_snitch}.each do |a|
  if cluster_conf[a] then node.default["cassandra"][a] = cluster_conf[a] end
end

# Determine the seed nodes, sorted so the list is the same across the cluster
node.default["cassandra"]["seed_list"] = cluster_conf["nodes"].collect do |k, v|
  v["broadcast_address"] if v["seed"]
end.compact.sort
if node["cassandra"]["seed_list"].empty?
  raise Chef::Exceptions::ConfigurationError, "Seed list cannot be empty"
end

# Check for any encryption option overrides
cluster_conf["encryption_options"].each do |k, v|
  node.default["cassandra"]["encryption_options"][k] = v
end

# Check if an initial_token was provided in the data bag
if node_conf["initial_token"]
  node.default["cassandra"]["initial_token"] = node_conf["initial_token"]
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
