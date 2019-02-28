#!/usr/bin/ruby

# ===============================================================================
# The structural body of Aranya, a general-purpose JSON-crawling spider for the
# recursive validation of 'response' data structures against a GraphQL
# introspection SDL (schema definition language).
# ===============================================================================
require 'singleton'						# dynamic dispatch done via one Validate

# -------------------------------------------------------------------------------
# I used to handle NoMethodError exceptions when dispatch found an unknown type,
# but now I've wrapped the send() in a respond_to?() test.
# -------------------------------------------------------------------------------
#def handle_exception(exception, explicit)
#	puts "[#{explicit ? 'EXPLICIT' : 'INEXPLICIT'}] #{exception.class}: #{exception.message}"
#	puts exception.backtrace.join("\n")
#end

# -------------------------------------------------------------------------------
# Dispatch types found in the response object to helper functions.
#
# TO-DO: replace with a general mechanism to find and validate against a typedef
# SDL and attempt to dispatch *optional* hand-curated type-specific test functions.
# -------------------------------------------------------------------------------
class Validate
	include Singleton					# just one central dispatcher

	# ---------------------------------------------------------------------------
	# TO-DO: general mechanism for getting a `__typedef` and gathering the SDL
	# instead of defining one function for each and every...
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
	v = Validate.instance				# we'd like a dispatcher, please

	typename = response['__typename']
#	typename = response['name']

	unless typename.nil?				# if there's a '_typename' at this level
		if v.respond_to?(typename)		# and validate knows about it
			v.send(typename)			# then give it a go
		else
			STDERR.puts "error: unknown __typename '#{typename}'; skipping."
		end
	end

	response.each do |pair|
		# printf( "%s (%s)\n", ' '*(depth*2), pair) # pretty-print the object

		if pair[1].is_a?(Hash)			# any children an object by themselves?
			spider(pair[1], sdl, depth+1 )	# recurse on that child
		end
	end
end
