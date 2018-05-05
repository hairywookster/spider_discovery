class Spider

  def self.discover_all_urls( config, result_file )
    Log.logger.info( "Starting spidering process" )
    Log.logger.info( "Using the supplied config\n#{config.to_json}" )
    Log.logger.info( "Results will be emitted into #{result_file}" )

    urls_from_sitemaps = SitemapUrlCollator.collate_urls( ConfigValidator.init_config( args[:config_file] ) )
    urls_to_spider = ( config.urls_to_spider + urls_from_sitemaps ).uniq
    Log.logger.debug( "Initial Urls to spider are\n#{urls_to_spider.join("\n")}" )

    #Note we may make this multi threaded later but for the moment lets keep things simple
    urls_visited_results = {}
    loop do
      url = urls_to_spider.pop
      process_url( url, urls_to_spider, urls_visited_results, config )
      report_progress( urls_visited_results, urls_to_spider )
      unless urls_to_spider.empty?
        sleep config.delay_between_requests_in_seconds
      end
      break if urls_to_spider.empty?
    end

    # todo implement reporting with contents of urls_to_spider

    File.open(config.result_file, "w") do |f|
      f.puts(urls_visited_results.to_json)
    end
  end

  def self.report_progress( urls_visited_results, urls_to_spider )
    num_urls_processed = urls_visited_results.size
    if num_urls_processed % 100 == 0   #todo make configurable
      Log.logger.info "Processed #{num_urls_processed} urls - #{urls_to_spider.size} urls remain"
    end
  end

  def self.process_url( url, urls_to_spider, urls_visited_results, config )
    if SpiderUtils.url_should_be_included?( url, collected_urls, config )
      Log.logger.debug( "Processing url=#{url}" )

      #todo implement me
      #   visit the url
      #   determine its result code + content type   add to urls_visited_results
      #   if html    determine any links it contains    add to urls_to_spider if not already present

    else
      Log.logger.debug( "Skipped url=#{url}" )
    end
  end

end