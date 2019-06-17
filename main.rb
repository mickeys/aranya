#!/usr/bin/env ruby
# ===============================================================================
# The entry point for Aranya, a general-purpose JSON-crawling spider for the
# recursive validation of '$ResponseFile' data structures against a GraphQL
# introspection $SdlFile (schema definition language).
#
# Currently used to test aranya, presumably to be used as a CI/CD yoke for
# the automated crawling from (for example) a Jenkins environment.
# ===============================================================================
require 'json'							# JSON (JavaScript Object Notation)
require 'pry-byebug'
require './spider.rb'					# the JSON-crawling spider

$VERBOSE=true # deeper in-program debugging

# -------------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------------
$ResponseFile = './json/cc_search_response.json'.freeze
$SdlFile = './json/ck_introspection.json'.freeze

$TypeMark = '__typename'.freeze

# -------------------------------------------------------------------------------
# Loop: Parse JSON file(s) and assign contents to local variable.
# -------------------------------------------------------------------------------
r = s = nil ;							# can't create local vars via eval :-/

[	[ 'r', "#{$ResponseFile}" ],		# that which was returned to us
	[ 's', "#{$SdlFile}" ]				# the source of truth
].each do |json_file|
	puts "#{json_file[1]}" if $VERBOSE
	begin
		eval "#{json_file[0]} = JSON.parse(File.read( \"#{json_file[1]}\" ))"
	rescue JSON::ParserError => e		# do if things went bad quickly
		STDERR.puts "fatal: #{e.class.name} error in '#{$ResponseFile}'; quitting."
		puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
		exit							# quit - not much to do if JSON is bad
	end
end

# -------------------------------------------------------------------------------
# Convert a standard GraphQL $SdlFile into a ruby hash (so we can search by typename).
# -------------------------------------------------------------------------------
sdl = Hash.new

s['data']['__schema']['types'].each do |t|
	unless t['fields'].nil?				# many entries have no fields
		sdl[ t['name'] ] = t['fields']	# capture fields for the ones that do
	end
end

spider( r['data'], sdl )				# validate a response against an SDL