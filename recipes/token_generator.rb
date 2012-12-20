#
# Cookbook Name:: casserole
# Recipe:: token_generator
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

# Token ID = (2**127 / num_nodes_in_dc * node_number + (dc_number * 100)
dc_list = node["cassandra"]["cluster_nodes"].collect do |k, v|
  v["datacenter"]
end.uniq.sort
dc_offset = dc_list.index(node["cassandra"]["datacenter"]) * 100
Chef::Log.info "Token generator calculated a DC offset of #{dc_offset}"
dc_nodes = node["cassandra"]["cluster_nodes"].collect do |k, v|
  k if v["datacenter"] == node["cassandra"]["datacenter"]
end.compact.sort
node_count = dc_nodes.length
Chef::Log.info "Token generator found #{node_count} nodes in this DC"
node_pos = dc_nodes.index(node["cassandra"]["node_id"])
Chef::Log.info "Token generator found this node's position as #{node_pos}"
node.default["cassandra"]["initial_token"] = 2**127 / node_count * node_pos +
  dc_offset

Chef::Log.info "Generated token of #{node["cassandra"]["initial_token"]}"

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
