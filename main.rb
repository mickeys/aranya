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
#RESPONSE = './json/introspection.json'.freeze	#

begin
	r = JSON.parse(File.read(RESPONSE))

	rescue JSON::ParserError => e
		STDERR.puts "error: #{e.class.name} error in '#{RESPONSE}'; quitting."
		exit
end

spider(r)
