require "rubygems"
require "bundler"

task :default => [:cookbook_test, :tailor, :foodcritic, :chefspec]

desc "Run knife cookbook syntax test"
task :cookbook_test do
  puts "Running knife cookbook syntax test..."
  puts %x{knife cookbook test -o .. casserole}
  $?.exitstatus == 0 or fail "Cookbook syntax check failed!"
end

desc "Run Tailor lint tests"
task :tailor do
  puts "Running Tailor lint tests..."
  puts %x{tailor */*.rb}
  $?.exitstatus == 0 or fail "Tailor lint tests failed!"
end

desc "Run Foodcritic lint tests"
task :foodcritic do
  puts "Running FoodCritic lint tests..."
  puts %x{foodcritic -f any .}
  $?.exitstatus == 0 or fail "Foodcritic lint tests failed!"
end

desc "Run ChefSpec unit tests"
task :chefspec do
  puts "Running ChefSpec unit tests..."
  puts %x{rspec}
  $?.exitstatus == 0 or fail "ChefSpec unit tests failed!"
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
