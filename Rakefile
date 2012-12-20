require "rubygems"
require "bundler"

task :default => [:cookbook_test, :tailor, :foodcritic, :chefspec]

desc "Run knife cookbook syntax test"
task :cookbook_test do
  puts %x{knife cookbook test -o .. casserole}
end

desc "Run Tailor lint tests"
task :tailor do
  puts %x{tailor */*.rb}
end

desc "Run Foodcritic lint tests"
task :foodcritic do
  puts %x{foodcritic -f any .}
end

desc "Run ChefSpec unit tests"
task :chefspec do
  puts %x{rspec}
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
