# What is "spidering"?

Spidering is a programming technique to exhaustively explore a data structure in the most computationally thrifty fashion, featuring a simple framework that allows maintenance and enhancements to happen in localized sections of the software.

## When is spidering appropriate?

Specific characteristics of the data structure that call out for spidering (or "crawling") include:

* complex contents
* arbitrary ordering
* arbitrary nesting to arbitrary depths

These characteristics preclude techniques similar iterating over a columnar table. A spider provides the flexibility to handle complex dynamic structures.

## How does a spider cover everything?

Spiders are _recursive_, meaning the spider divides the work and calls itself, which in turn may decide it's appropriate to divide the work and call itself. In this way the spider tackles each part of the data structure with all corners given attention before everything is finished.

The entire implementation of the spider is as follows; you can see how it tries to process the result it's given in `doTopLevelProcessing()` and then examines the response and calls itself on "children" portions of the data. If the data is of type `Hash` it's a name-value pair and easy to aportion to a child spider. If it's an `Array` then it's a list of name-value pairs so the spider iterates over the list, delegating each list item to a child spider. Sooner or later the entire structure is consumed.

```ruby
def spider( response )
	doTopLevelProcessing( response )

	response.each do |pair|
		if pair[1].is_a?( Hash )
			spider( pair[1] )
		elsif pair[1].is_a?( Array )
			pair[1].each do |portion|
				spider( portion )
			end
		end
	end
end
```

That's it! Throw any type of nested data struture, of any "width" and "length" (also known as "depth"), and this simple algorithm will crawl it, isolating and processing each element. All the "smarts" are moved outside into a processing function.

## JSON

Now you abstractly know how a spider crawls a data structure.

Let's look at the following bakery's data structure, which is in JSON (JavaScript Object Notation) object. It describes a rainbow sprinkle supreme donut. 

```json
{
	"id":1,
	"type":"donut",
	"name":"rainbow sprinkle supreme",
	"image":{
		"url":"https://server/path/to/images/0001.jpg",
		"text":"our best-selling breakfast treat",
		"width":200,
		"height":200
	},
	"thumbnail":{
		"url":"https://server/path/to/images/thumbnails/0001.jpg",
		"text":"rainbows!",
		"width":32,
		"height":32
	},
	"reviews":[
		{
			"id":1,
			"reviewer":"Jane Q. Public",
			"rating":9,
			"text":"Wonderfully tasty with crunchy sprinkles."
		},
		{
			"id":2,
			"reviewer":"Bartholemew Dalrymple",
			"rating":2,
			"text":"Not smooth at all :-/"
		}
	]
}
```

<!--

Here's another way to view the same thing:

<table style="font-size:90%"><tbody><tr><td><div>id</div></td><td><div>1</div></td></tr><tr><td><div>type</div></td><td><div>donut</div></td></tr><tr><td><div>name</div></td><td><div>rainbow sprinkle supreme</div></td></tr><tr><td colspan="2"><div><strong>image</strong></div><table style="width:100%"><tbody><tr><td><div>url</div></td><td><div>https://server/path/to/images/0001.jpg</div></td></tr><tr><td><div>text</div></td><td><div>our best-selling breakfast treat</div></td></tr><tr><td><div>width</div></td><td><div>200</div></td></tr><tr><td><div>height</div></td><td><div>200</div></td></tr></tbody></table></td></tr><tr><td colspan="2"><div><strong>thumbnail</strong></div><table style="width:100%"><tbody><tr><td><div>url</div></td><td><div>https://server/path/to/images/thumbnails/0001.jpg</div></td></tr><tr><td><div>text</div></td><td><div>rainbows!</div></td></tr><tr><td><div>width</div></td><td><div>32</div></td></tr><tr><td><div>height</div></td><td><div>32</div></td></tr></tbody></table></td></tr><tr><td colspan="2"><div><strong>reviews</strong></div><table style="width:100%"><tbody><tr><td><div>id</div></td><td><div>reviewer</div></td><td><div>rating</div></td><td><div>text</div></td></tr><tr><td><div>1</div></td><td><div>Jane Q. Public</div></td><td><div>9</div></td><td><div>Wonderfully tasty with crunchy sprinkles.</div></td></tr><tr><td><div>2</div></td><td><div>Bartholemew Dalrymple</div></td><td><div>2</div></td><td><div>Not smooth at all :-/</div></td></tr></tbody></table></td></tr></tbody></table>

-->

If we pass this structure to our spider (instance #1), it'll encounter the `"id":1` and do something with it. It'll move down until it reaches the `"image":{` part, which it sees as a nested hash, and it'll hand just that chunk to a just-created copy (#2) of itself. The original spider will do the same with the `"thumbnail":{` chunk (#3) and continue to the `"reviews":[` line, which it recognises as an array of things (which themselves are hashes), and it'll iterate over the array, spinning up copies of itself (#4 and #5) and handing one array element to each.

Each of the spiders handle their portion of the work, dividing and handing off the children as necessary, and when done they expire, handing control back to their parent. These spiders don't need any external coordination system because this data structure can be divided and processed without depending upon anyone else. There are mechanisms for other domain spaces that need coordination.

## Testing and validation

There are two types of testing that can be done with this kind of data structure:

* implicit testing based upon the name - `url` implies a valid URI that complies with [RFC 3986](https://tools.ietf.org/html/rfc3986)
* relationship testing based upon specification - an image requires a url and text while the width and height are optional and can be computed from the image, whereas for a thumbnail only the url is required

In the example spider all is done in `doTopLevelProcessing()` while for a real-world one would probably break each of the above types into their own functions; the implicit rules can most likely be shared across many data structures for that probelm domain while the relationship-testing would vary between items encountered.

## Conclusion

A spider is a simple, time-tested solution to tackling complex arbitrary datasets that provides a framework for exhaustive testing of all sorts of similar data structures for a given domain. From web crawlers to data validators, spiders are crawling your Internet and hopefully will becoming to a testbed near you!