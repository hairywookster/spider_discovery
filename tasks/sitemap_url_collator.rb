class SitemapUrlCollator

  #See https://www.sitemaps.org/protocol.html

  def self.collate_urls( config )
    collected_urls = []
    headers = SpiderUtils.build_headers( config )
    if config.optional.sitemap_urls.empty?
      Log.logger.info( "Collating urls from configured sitemaps")
      collected_urls
    else
      Log.logger.info( "Collating urls from configured sitemaps")
      sitemaps_to_process = config.optional.sitemap_urls.clone
      process_sitemaps( sitemaps_to_process, headers, config, collected_urls )
      Log.logger.info("Located urls\n#{collected_urls.join("\n")}")
      collected_urls
    end
  end

private

  def self.process_sitemaps( sitemaps_to_process, headers, config, collected_urls )
    processed_sitemaps = []
    loop do
      sitemap_url = sitemaps_to_process.pop
      processs_sitemap( sitemap_url, config, headers, sitemaps_to_process, processed_sitemaps, collected_urls )
      unless sitemaps_to_process.empty?
        sleep config.delay_between_requests_in_seconds
      end
      break if sitemaps_to_process.empty?
    end
  end

  def self.processs_sitemap( sitemap_url, config, headers, sitemaps_to_process, processed_sitemaps, collected_urls )
    sitemap_content = get_sitemap_content( sitemap_url, headers )
    processed_sitemaps << sitemap_url
    unless sitemap_content.nil?

      begin
        Log.logger.debug( "Sitemap sitemap_url=#{sitemap_url} contains\n#{sitemap_content}" )
        as_xml_doc = REXML::Document.new(sitemap_content)

        as_xml_doc.elements.each('sitemapindex/sitemap/loc') do |location_element|
          url = location_element.text
          if SpiderUtils.url_should_be_included?( url, sitemaps_to_process, config )
            sitemaps_to_process << url
          end
        end

        as_xml_doc.elements.each('sitemapindex/urlset/url/loc') do |location_element|
          url = location_element.text
          if SpiderUtils.url_should_be_included?( url, collected_urls, config )
            collected_urls << url
          end
        end

      rescue => ex
        Log.logger.error( "Error: sitemap_url=#{sitemap_url} contents could not be parsed as xml")
      end

    end
  end

  def self.get_sitemap_content( sitemap_url, headers )
    begin
      agent = Mechanize.new do |a|
        a.agent.verify_mode = OpenSSL::SSL::VERIFY_NONE   #disabled SSL check
        a.agent.gzip_enabled = false                      #gzip seems flaky so disabled
      end
      page = agent.get( sitemap_url, nil, nil, headers )
      if 200.eql?( page.code.to_i )
        Log.logger.info( "Success: Get sitemap_url=#{sitemap_url}")
        page.body
      else
        Log.logger.error( "Error: Could not GET sitemap_url=#{sitemap_url} response code=#{page.code}")
        nil
      end
    rescue Mechanize::ResponseCodeError => ex
      Log.logger.error( "Error: Could not GET sitemap_url=#{sitemap_url}")
      nil
    end
  end

end