#!/usr/bin/ruby

# ===============================================================================
# The structural body of Aranya, a general-purpose JSON-crawling spider for the
# recursive validation of '$Response' data structures against a GraphQL
# introspection $SDL (schema definition language).
# ===============================================================================
require 'singleton'						# dynamic dispatch done via one Validate
require 'pry-byebug'

# -------------------------------------------------------------------------------
# I used to handle NoMethodError exceptions when dispatch found an unknown type,
# but now I've wrapped the send() in a respond_to?() test.
# -------------------------------------------------------------------------------
#def handle_exception(exception, explicit)
#	puts "[#{explicit ? 'EXPLICIT' : 'INEXPLICIT'}] #{exception.class}: #{exception.message}"
#	puts exception.backtrace.join("\n")
#end

# -------------------------------------------------------------------------------
# Dispatch types found in the $Response object to helper functions.
#
# TO-DO: replace with a general mechanism to find and validate against a typedef
# $SDL and attempt to dispatch *optional* hand-curated type-specific test functions.
# -------------------------------------------------------------------------------
class Validate
	include Singleton					# just one central dispatcher

	# ---------------------------------------------------------------------------
	# ---------------------------------------------------------------------------
	def test
		puts 'TEST'
	end

	def car
		puts 'car'
	end

	def person
		puts 'person'
	end
end

# -------------------------------------------------------------------------------
def spider( response, sdl, depth=0 )

#exit if depth > 3

	v = Validate.instance				# we'd like a dispatcher, please

	printf( "%s%s\n", ' '*(depth*2), 'Response keys:' ) if $VERBOSE
	printf( "%s%s\n", ' '*(depth*2), response.keys[0] ) if $VERBOSE

	typename = response[ $TypeMark ]
=begin
	unless typename.nil?				# if there's a '_typename' at this level

		# -----------------------------------------------------------------------
		# Dispatch if there's a typename-specific validator
		# -----------------------------------------------------------------------
		if v.respond_to?(typename)		# and validate knows about it
			v.send(typename)			# then give it a go

#		else							# is ok, not every level has a typename
#			STDERR.puts "error: unknown #{$TypeMark} '#{typename}'; skipping."
		end

		# -----------------------------------------------------------------------
		# Make a array of all the 'name' elements at this level of the sdl.
		#
		# TO-DO: move this and make global hash of typename and top-level members
		# -----------------------------------------------------------------------
		definition = []
		sdl[typename].each do |schema|
			schema.each do |member|
				definition << member[1] if member[0] == 'name'
			end
		end

		# -----------------------------------------------------------------------
		# Compare response object (what exists) against the SDL (which contains
		# all that is permitted).
		# -----------------------------------------------------------------------
		response.each do |pair|
			printf( "%s%s\n", ' '*((depth*2)+2), pair[0] ) if $VERBOSE
			unless typename != $TypeMark || definition.include?( pair[0] )
				STDERR.puts "error: #{typename} doesn't include #{pair[0]}."
			else
				puts "found #{pair[0]} in #{typename}" if $DEBUG
			end
		end
	end
=end
	# ---------------------------------------------------------------------------
	# Having checked this JSON level, recurse over children of this level.
	# ---------------------------------------------------------------------------
	response.each do |pair|
#binding.pry
		printf( "%s%d checking %s\n", ' '*((depth*2)+2), depth, pair[1].to_s[0,80] ) if $VERBOSE

		if pair[1].is_a?(Hash)			# any children an object by themselves?

			printf( "%s%d 1_would_spider %s %s %s\n", ' '*((depth*2)+2), depth, pair[1].class, pair[0], pair[1].to_s[0,80] ) if $VERBOSE
			spider( pair[1], sdl, depth+1 )	# recurse on that child

		elsif pair[1].is_a?(Array)		# an array of somethings? iterate!

			puts 'found an array'
			pair[1].each do |thing|
#				printf( "%s%d would_spider %s %s %s\n", ' '*((depth*2)+2), depth, pair[1].class, pair[0], thing.to_s[0,80] ) if $VERBOSE
				printf( "%s%d 2_would_spider %s %s %s\n", ' '*((depth*2)+2), depth, thing.class, thing.to_s[0,80], thing.to_s[0,80] ) if $VERBOSE

				spider( thing, sdl, depth+1 )	# recurse on that child
			end

		else
			printf( "%s%d rejecting %s %s %s\n", ' '*((depth*2)+2), depth, pair[1].class, pair[0], pair[1].to_s[0,80] ) if $VERBOSE
		end
	end
end
