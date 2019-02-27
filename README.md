# aranya - spidering 'response' JSON objects

_Aranya_ ([Catalan](https://en.wikipedia.org/wiki/Catalan_language) for "spider") is a general-purpose [JSON](https://www.json.org/)-crawling spider for the recursive validation of 'response' data structures against a [GraphQL](https://graphql.org/) [introspection](https://graphql.org/learn/introspection/) SDL ([schema definition language](https://graphql.org/learn/schema)), itself also a JSON response.

Why? Because there's a general-purpose need for ensuring that responses are valid, fit for further consumption. It's defensive programming for a use case that appears whenever you request information and recieve a response in a JSON format (which also has an accompanying SDL).

_Aranya_ will exhaustively walk any and all response objects, recursively validating each part of the response by:

<img src='./images/20150405_spider.png' align='right' width='40%' hspace='10' vspace='10'>

1. automatically testing the `__typedef` against the current SDL introspection (reflection) to semantically verify the existence and contents of all the data struct members, and

2. executing human-curated semantic tests which confirm relational requirements ("when this is present then those items must be...")

_Aranya_ can be integrated into a continuous integration (CI) or continuous development (CD) build process; providing a scheduled, constant, significant regression test using the same live SDL as the apps being built.

# Advantages to using a spider architecture

* Exhaustive exploration of live response objects using real, non-trivial queries (or lesser examinations made from human-compiled lists of "what's important" at the time of test-writing).

* Having the spider be a first-class consumer of development's GraphQL efforts allows _aranya_ to automatically - without any human involvement - remain in sync with changes and enhancements in the SDL.

* Exhaustive and dynamically-updated coverage of all response elements without concern for order, format, or quantity.

# Components

_Aranya_ consists of the following general-purpose modules:

1. **[done]** The main spider mechanism to crawl arbitrary JSON trees (spider.rb)
2. A tool to digest the current SDL into an actionable test routine
3. Consuming the digest and dispatching testing through the crawl
4. Adding human-curated type-specific contextually-appropriate tests
5. Integrating into the CI pipeline