#!/usr/bin/ruby
# ===============================================================================
# The entry point for Aranya, a general-purpose JSON-crawling spider for the
# recursive validation of '$ResponseFile' data structures against a GraphQL
# introspection $SdlFile (schema definition language).
#
# Currently used to test aranya, presumably to be used as a CI/CD yoke for
# the automated crawling from (for example) a Jenkins environment.
# ===============================================================================
require 'json'							# JSON (JavaScript Object Notation)
require './spider.rb'					# the JSON-crawling spider

# -------------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------------
$ResponseFile = './json/cc_search_response.json'.freeze
$SdlFile = './json/introspection.json'.freeze
$TypeMark = '__typename'.freeze

# -------------------------------------------------------------------------------
# Loop: Parse JSON file and assign contents to local variable.
# -------------------------------------------------------------------------------
r = s = nil ;							# can't create local vars via eval :-(
[['r', "#{$ResponseFile}"], ['s', "#{$SdlFile}"]].each do |json_file|
	begin
	eval "#{json_file[0]} = JSON.parse(File.read( \"#{json_file[1]}\" ))"
	rescue JSON::ParserError => e
		STDERR.puts "fatal: #{e.class.name} error in '#{$ResponseFile}'; quitting."
		exit							# quit - not much to do if JSON is bad
	end
end

#p s['data']['__schema']['types']['RootQuery'].to_s
##	p JSON.parse( s['data']['__schema']['types']['RootQuery'].to_s )
#exit

# -------------------------------------------------------------------------------
# Convert a standard GraphQL $SdlFile into a ruby hash (so we can search by typename).
# -------------------------------------------------------------------------------
sdl = Hash.new

#puts "s.l = #{s.length} #{s['data']['__schema']['types'].length}"
#i=0
s['data']['__schema']['types'].each do |t|
#	name = t['name']
	unless t['fields'].nil?				# many entries have no fields
		sdl[ t['name'] ] = t['fields']
	end

#	j=0
#	unless t['fields'].nil?				# many entries have no fields
#		t['fields'].each do |row|
#			puts "\t#{i} #{name} #{j} %25s" % [row.to_s ]
#			j = j+1
#		end
#	end
#	i = i+1

#p '--- DURING -------------------------------------'
#	value = t['fields'].to_json
#	puts "#{name} ===> #{value}"
#p '--- AFTER -------------------------------------'
#	puts "#{t['fields'].to_json}"		# serialize the entry
###	sdl[:name] = value
end

#puts "dict len = #{sdl.length}"
#p sdl['AppDashboard'].class
#
#sdl['AppDashboard'].each do |x|
#	k=0
#	puts x['name']
#	x.each do |y|
#		puts "#{k} #{y}"
#		k=k+1
#	end
#end
##exit

#depth=1
#	r.each do |pair|
#		printf( "%s (%s)\n", ' '*(depth*2), pair) # pretty-print each member
#	end

##s['data']['__schema']['types'][0]
#sdl.each do |x|
#	puts "\t --> #{x}"
#end

spider( r['data'], sdl )						# validate a $ResponseFile against an $SdlFile
#		s['data']['__schema']['types'] )
