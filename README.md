# spider_discovery
A simple spider tool to identify testable areas of a website

## Introduction
A frequent task when maintaining web sites is to validate that the pages in the site are functioning correctly.
We frequently want to test multiple aspects of these pages.
But first we need a way to identify the existing pages.
Once we have discovered our pages we can use the output of the spider in subsequent automated test tools.

A spider essentially runs the following procees
* Add initial URL to visit to "URLs to be visited"
* Visit URL
* Add URL to list of "visited URLs"
* Scan content for referenced URLs
* Add each URL to the list of "URLs to be visited", if it has not already been visited
* repeat from step 2 until no more "URLs to be visited"

Most websites, ignoring Single Page Apps, consist of multiple pages, with each page containing multiple links to areas inside and outside of the primary web site. Often though many pages cannot be located or reached solely by following all links from a starting page. 
We need to consider the following additional aspects.
- Some sites have a homepage and good SEO linkage, making indexing of available pages relatively trivial.
- Some sites will provide a sitemap that can be used to identify initial pages that should be accessible.
- Sometimes there will be pages that are not easy to reach, that are not in the sitemap, but that our domain knowledge tells us exist.
  - Additional example is where custom JS is used for links, such that there are no real links present.
- We may need to test multiple versions of a site, for example. in dev, in stage, in production often using different domains or hosts.
- We may need to pass specific cookies on requests
  - We may have areas of a site that only function when you are signed in for example
- We may need to pass specific useragents on requests
  - We may have different physical responses depending on UserAgent that pre-date Responsive web design.
  - We may have different types of clients accessing the same underlying urls but receiving different content.
- We may need to pass specific headers to incite specific responses.
- We may have different types of user states such as guest, signed-in, etc that we need to be able to validate.
- We may want to ignore specific URLs
- We may want to continue spidering into a set of related domains
  - For example www.example.com may reference abc.example.com and we may wish to spider both systems as one.

## Installation
- Install rvm (assuming your on a flavor of linux) (otherwise see windows alternative) 
- Install Ruby 2.3+
- Optionally setup your .rvmrc and gem sandbox 
- gem install bundler
- bundle install

## Configuration
Rather than depending on an arcane and ever growing set of command line variables, lets keep things simple and use a 
single input of a json configuration file.

Storing the configuration as json gives us several advantages.
- It is easy to validate
- It is human readable
- It can be easily compared with other configurations
- It is easy to extend  

The config will support mandatory and optional settings as follows.
````json
{
  "log_level": "info",
  "domains_to_spider": [ "bbc.co.uk", "www.bbc.com" ],
  "urls_to_spider": [ "https://bbc.co.uk" ],
  "user_agent_for_requests": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.139 Safari/537.36",
  "delay_between_requests_in_seconds": 0.5,
  "report_progress_every_n_urls_processed": 100,
  "optional": {
    "urls_to_ignore": [ ],
    "sitemap_urls": [ "https://bbc.co.uk/sitemap.xml" , "https://www.bbc.com/sitemap.xml"],
    "headers_for_requests": { },
    "cookies_for_requests": { }
  }
}
````

### General notes
Note the [ ] notation indicates the tool expects zero or more string values.
The { } notation indicates the tool expects a set of key->value pairs. 
The optional block can be left empty, or configured as you see fit.

### log_level (mandatory)
The log_level can be set to one of the following
- debug
- info
- warn
- error
- fatal

### domains_to_spider (mandatory)
The domains_to_spider array must contain 1 or more domains that should be spidered.

### urls_to_spider (mandatory)
The urls_to_spider array must contain at least one fully qualified url to start with, but can be (n) fully qualified urls including urls that you want 
to test but that the spider will not locate on its own

### user_agent_for_requests (mandatory)
The user_agent_for_requests string must be set to a user agent of your choosing that will be sent on all requests.
If you find you need to request your pages with a list of user agents, you should create a separate config file per 
user agent.

### delay_between_requests_in_seconds (mandatory)
The delay_between_requests_in_seconds must be set to a positive float >= 0 (i.e. 0.1 is 100 milliseconds, 1 is 1 second) 
and will be used to set the time between each request.

### report_progress_every_n_urls_processed
The report_progress_every_n_urls_processed must be set to a value >= 0.
If set to 0 now progress will be emitted when running in info logging level.
If set to say, 100, you will see a statement after every 100 urls have been processed

### urls_to_ignore (optional)
The urls_to_ignore array can contain 0 or more fully qualified urls to ignore when spidering.
We will add support for regular expressions later.

### sitemap_urls (optional)
The sitemap_urls array can contain 0 or more fully qualified sitemap urls to reference w.r.t. URLs we want to add to the list of URLs 
to be spidered. We will discuss the types of sitemap content we will support below.

### headers_for_requests (optional)
The headers_for_requests hash can be set to (n) key->value pairings of form
```json
{
   "some header": "some value",
   "some other header": "some other value"   
}
```
These will be sent on each request.
An example might be where you are testing a site that returns different content for different headers such as useragent,
language and other similar content differentiators. 

### cookies_for_requests (optional)
The cookies_for_requests hash can be set to (n) key->value pairings of form
```json
{
   "some cookie name": "some cookie value",
   "some other cookie name": "some other cookie value"   
}
```
These will be sent on each request.

## Validating your config
Config files can be validated easily, to run the validation simply run
````
rake validate_config["<path to the config file>"]
````

## Sitemap collation
You can pre-test the output from the collation of urls included in your configured sitemap(s)
by running the following command
````
rake collate_sitemap_urls["<path to the config file>"]
````
The process will find and follow sitemapindex/sitemap/loc (other sitemaps) and all sitemapindex/urlset/url/loc.
It only follows and collates urls that pass the rules defined in the domains_to_spider and urls_to_ignore configuration.
The requests to the sitemap are made with the configured user_agent_for_requests, headers_for_requests, cookies_for_requests. 

## Running the spider
Once your happy that your config is valid and your sitemaps are configured (or skipped) you can run the spider in anger.
If you are at all unsure always set the value of delay_between_requests_in_seconds to a higher figure, say 10 seconds,
to allow you to stop the process if required.

To run the process run this command
````
run_discovery["<path to the config file>", "<path to output report folder>"]
````

## Output
The tool generates 3 outputs
A simple console summary of the result
A detailed json file of the result - for consumption by other tools
A detailed html file of the result - for easy viewing

## Licence
Software is released under the [MIT License](LICENSE).
