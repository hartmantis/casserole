#
# Cookbook Name:: casserole
# Spec:: configs_test
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

require File.expand_path("../support/helpers.rb", __FILE__)

describe_recipe "casserole::configs" do
  include Helpers::Casserole

  {
    "cassandra.in.sh" => [
      /^CASSANDRA_CONF=\/etc\/cassandra\/conf$/,
      /^for jar in \/usr\/share\/cassandra\/lib\/\*\.jar; do$/
    ],
    "cassandra-env.sh" => [],
    "cassandra.yaml" => [
      /^cluster_name: 'Casserole Cluster'$/,
      /^initial_token: $/,
      /- seeds: "127\.0\.0\.1"$/,
      /^listen_address: 1\.2\.3\.4$/,
      /^broadcast_address: $/,
      /^endpoint_snitch: SimpleSnitch$/
    ],
    "cassandra-rackdc.properties" => [
      /^dc=DC1$/,
      /^rack=RAC1$/
    ],
    "cassandra-topology.properties" => [
      /^# Cassandra Node IP=Data Center:Rack\n\n# default for/,
      /^default=DC1:RAC1$/
    ]
  }.each do |f, lines|
    it "creates #{f}" do
      skip("Need to debug these")
      file(f).must_exist
      lines.each do |line|
        file(f).must_match line
      end
    end
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
