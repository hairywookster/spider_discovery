class Spider

  def self.discover_all_urls( config_file )
    puts "This method will pull in the config from #{config_file} and run the spider-ing process to discover all urls"

    config = ConfigValidator.validate_config_file( config_file )
    Log.init_logger( config.log_level )

    #todo implement me
    #add sitemap config and validation
    #add manual urls and validation
    #add domains to spider
    #add domains to ignore
    #add urls to ignore
    #add useragent setting and validation/optional
    #add extra headers setting and validation/optional
    #
    # implement spider activity
    # implement reporting
    # implement pass-result-forward-as-json for other tools to use
  end

end