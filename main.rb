#!/usr/bin/ruby
# ===============================================================================
# The entry point for Aranya, a general-purpose JSON-crawling spider for the
# recursive validation of 'response' data structures against a GraphQL
# introspection SDL (schema definition language).
#
# Currently used to test aranya, presumably to be used as a CI/CD yoke for
# the automated crawling from (for example) a Jenkins environment.
# ===============================================================================
require 'json'							# JSON (JavaScript Object Notation)
require './spider.rb'					# the JSON-crawling spider
require 'pp'

RESPONSE = './json/cars.json'.freeze	#
#RESPONSE = './json/cc_search_response.json'.freeze	#
SDL = './json/introspection.json'.freeze	#

# -------------------------------------------------------------------------------
# Iterate over all JSON files that need opening & assign them to local variables.
# -------------------------------------------------------------------------------
r = s = nil ;							# can't create local vars via eval :-(
[['r', "#{RESPONSE}"], ['s', "#{SDL}"]].each do |json_file|
	begin
	eval "#{json_file[0]} = JSON.parse(File.read( \"#{json_file[1]}\" ))"
	rescue JSON::ParserError => e
		STDERR.puts "fatal: #{e.class.name} error in '#{RESPONSE}'; quitting."
		exit							# quit - not much to do if JSON is bad
	end
end

#p r['data']['__schema']['types'].length
depth=1
	r.each do |pair|
		printf( "%s (%s)\n", ' '*(depth*2), pair) # pretty-print each member
	end

spider( r, s )							# validate a response against an SDL
