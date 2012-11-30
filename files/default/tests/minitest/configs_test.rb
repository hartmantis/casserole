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
#     http://www.apache.org/licenses/LICENSE-2.0
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

    it "creates cassandra-env.sh with the proper stack size" do
        f = "#{node["cassandra"]["conf_dir"]}/cassandra-env.sh"
        ss = node["cassandra"]["jvm_stack_size"]

        file(f).must_exist
        file(f).must_match(/^    JVM_OPTS="\$JVM_OPTS -Xss#{ss}"$/)
    end
end

# vim:et:fdm=marker:sts=4:sw=4:ts=4:
