#
# Cookbook Name:: casserole
# Spec:: default_test
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

describe_recipe "casserole::default" do
    include Helpers::Casserole

    it "installs the Sun Java 1.6 via the java cookbook" do
        o = %x{java -version 2>&1}.split("\n")
        o[0].must_match(/^java version "1\.6.*$/)
        o[1].must_match(/^Java\(TM\) SE Runtime Environment.*$/)
    end 

    it "enables and starts the appropriate services" do
        ([node["cassandra"]["name"]] + 
                node["cassandra"]["extra_services"]).each do |s|
            # Minitest needs a process name and chokes on "opscenterd"
            unless s == "opscenterd"
                service(s).must_be_enabled
                service(s).must_be_running
            else
                res = %x{service #{s} status}
                $?.exitstatus.must_equal 0
            end
        end
    end
end

# vim:et:fdm=marker:sts=4:sw=4:ts=4:
