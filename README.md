# spider_discovery
A simple spider tool to identify testable areas of a website

## Introduction
A frequent task when maintaining web sites is to validate that the pages in the site are functioning correctly.
We frequently want to test multiple aspects of these pages to determine if our system is working correctly.
But first we need a way to identify the existing pages.
Once we have discovered our pages we can use the output of the spider in subsequent automated test tools.

A spider essentially runs the following procees
* Add initial URL to visit to "URLs to be visited"
* Visit URL
* Add URL to list of "visited URLs"
* Scan content for referenced URLs
* Add each URL to the list of "URLs to be visited", if it has not already been visited
* repeat from step 2 until no more "URLs to be visited"

Most websites, ignoring Single Page Apps, concist of multipe pages, with each page containing multiple links to areas inside and outside of the primary web site. Often though many pages cannot be located or reached solely by following all links from a starting page. 
We need to consider the following additional aspects.
- Some sites have a homepage and good SEO linkage, making indexing of available pages relatively trivial.
- Some sites will provide a sitemap that can be used to indentify initial pages that should be accessible.
- Sometimes there will be pages that are not easy to reach, that are not in the sitemap, but that our domain knowledge tells us exist.
  - Additional example is where custom JS is used for links, such that there are no real links present.
- We may need to test multiple versions of a site, for example. in dev, in stage, in production often using different domains or hosts.
- We may need to pass specific cookies on requests
  - We may have areas of a site that only function when you are signed in for example
- We may need to pass specific useragents on requests
  - We may have different physical responses dependening on UserAgent that pre-date Responsive web design.
  - We may have different types of clients accessing the same underlying urls but receiving different content.
- We may need to pass specific headers to incite specific responses.
- We may have different types of user states such as guest, signed-in, etc that we need to be able to validate.
- We may want to ignore specific URLs
- We may want to continue spidering into a set of related domains
  - For example www.example.com may reference abc.example.com and we may wish to spider both systems as one.

## Installation
# Install rvm (assuming your on a flavor of linux) (otherwise see windows alternative) 
# Install Ruby 2.3+
# Optionally setup your .rvmrc and gem sandbox 
# gem install bundler
# bundle install

## Usage
TODO (configure, run, output)

## Licence
Software is released under the [MIT License](LICENSE).
