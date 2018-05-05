class Spider

  FAILED = 'FAILED'

  def self.discover_all_urls( config, result_file )
    Log.logger.info( "Starting spidering process" )
    Log.logger.info( "Using the supplied config\n#{config.to_json}" )
    Log.logger.info( "Results will be emitted into #{result_file}" )

    headers = SpiderUtils.build_headers( config )
    urls_from_sitemaps = SitemapUrlCollator.collate_urls( config )
    urls_to_spider = ( config.urls_to_spider + urls_from_sitemaps ).uniq
    Log.logger.debug( "Initial Urls to spider are\n#{urls_to_spider.join("\n")}" )

    #Note we may make this multi threaded later but for the moment lets keep things simple
    urls_visited_results = {}
    loop do
      url = urls_to_spider.pop
      process_url( url, urls_to_spider, urls_visited_results, config, headers )
      report_progress( urls_visited_results, urls_to_spider, config.report_progress_every_n_urls_processed )
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

  def self.report_progress( urls_visited_results, urls_to_spider, report_progress_every_n_urls_processed )
    num_urls_processed = urls_visited_results.size
    if report_progress_every_n_urls_processed > 0 && (num_urls_processed % report_progress_every_n_urls_processed) == 0
      Log.logger.info "Processed #{num_urls_processed} urls - #{urls_to_spider.size} urls remain"
    end
  end

  def self.process_url( url, urls_to_spider, urls_visited_results, config, headers )
    if SpiderUtils.url_should_be_included?( url, urls_to_spider, config )
      Log.logger.debug( "Processing url=#{url}" )
      begin
        #https://github.com/jaimeiniesta/metainspector
        meta_inspector_page = MetaInspector.new( url,
                                                 :connection_timeout => 30,
                                                 :read_timeout => 10,
                                                 :retries => 3,
                                                 :allow_redirections => true,
                                                 :allow_non_html_content => false,
                                                 :headers => headers,
                                                 :download_images => false,
                                                 :faraday_options => { ssl: { verify: false } })

        response_code = meta_inspector_page.response.status.to_i
        urls_visited_results[url] = response_code
        if 200.eql?( response_code )
          meta_inspector_page.links.internal.each do |located_url|
            unless urls_visited_results.include?( located_url )
              if SpiderUtils.url_should_be_included?( located_url, urls_to_spider, config )
                urls_to_spider << located_url
              end
            end
          end
        else
          Log.logger.error( "Error: Non 200 response code=#{response_code} for #{url}" )
        end

      rescue Faraday::TimeoutError => ex
        Log.logger.error( "Error: Timeout connecting to #{url}. Faraday::TimeoutError#{ex}" )
        urls_visited_results[url] = FAILED
      rescue Faraday::ConnectionFailed => ex
        Log.logger.error( "Error: Connection failed connecting to #{url}. Faraday::ConnectionFailed#{ex}" )
        urls_visited_results[url] = FAILED
      rescue MetaInspector::RequestError  => ex
        Log.logger.error( "Error: Request failed to #{url}. MetaInspector::RequestError#{ex}" )
        urls_visited_results[url] = FAILED
      rescue Net::OpenTimeout => ex
        Log.logger.error( "Error: Open Timeout connecting to #{url}. Net::OpenTimeout#{ex}" )
        urls_visited_results[url] = FAILED
      rescue MetaInspector::TimeoutError => ex
        Log.logger.error( "Error: Timeout connecting to #{url}. MetaInspector::TimeoutError#{ex}" )
        urls_visited_results[url] = FAILED
      rescue FaradayMiddleware::RedirectLimitReached => ex
        Log.logger.error( "Error: Redirect limit reached connecting to #{url}. FaradayMiddleware::RedirectLimitReached#{ex}" )
        urls_visited_results[url] = FAILED
      end
    else
      Log.logger.debug( "Skipped url=#{url}" )
    end
  end

end