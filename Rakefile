#!/usr/bin/env ruby
#Run   rake -T   to see what is available
require 'rubygems'
require 'rake'
require 'active_support/all'
require 'fileutils'
require 'json'
require 'mechanize'
require 'methodize'
require 'metainspector'
require 'logger'
require 'rexml/document'
require 'nokogiri'
require 'erb'

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

desc 'runs the discovery using the config specified. Usage: run_discovery["<path to the config file>", "<path to output folder>"]'
task :run_discovery, :config_file, :result_json_file do |t, args|
  Spider.discover_all_urls( ConfigValidator.init_config( args[:config_file] ), args[:result_folder] )
end

desc 'validates the config file is valid. Usage: validate_config["<path to the config file>"]'
task :validate_config, :config_file do |t, args|
  ConfigValidator.validate_config_file( args[:config_file] )
end

desc 'collates urls from the sitemaps specified in the config file. Usage: collate_sitemap_urls["<path to the config file>"]'
task :collate_sitemap_urls, :config_file do |t, args|
  SitemapUrlCollator.collate_urls( ConfigValidator.init_config( args[:config_file] ) )
end