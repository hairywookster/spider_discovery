#!/usr/bin/env ruby
#Run   rake -T   to see what is available
require 'rubygems'
require 'rake'
require 'fileutils'
require 'json'
require 'mechanize'
require 'methodize'
require 'metainspector'
require 'logger'

def auto_require(path)
  Dir["#{File.dirname(__FILE__)}#{path}/*.rb"].each do |file|
    require(file)
  end
end

auto_require '/lib'
auto_require '/tasks'


desc 'Emits help and summary of commands'
task :help do
  print <<EOF
--------------------------------------------------------------
Spider Discovery
--------------------------------------------------------------
Run    rake -T    for more information about available tasks
EOF
end

task :default => 'help'

desc 'runs the discovery using the config specified. Usage: run_discovery["<path to the config file>"]'
task :run_discovery, :config_file do |t, args|
  Spider.discover_all_urls( args[:config_file] )
end

desc 'validates the config file is valid. Usage: validate_config["<path to the config file>"]'
task :validate_config, :config_file do |t, args|
  ConfigValidator.validate_config_file( args[:config_file] )
end