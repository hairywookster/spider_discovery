class SitemapUrlCollator

  #See https://www.sitemaps.org/protocol.html

  def self.collate_urls( config )
    collected_urls = []
    if config.optional.sitemap_urls.empty?
      Log.logger.info( "Collating urls from configured sitemaps")
      collected_urls
    else
      Log.logger.info( "Collating urls from configured sitemaps")
      sitemaps_to_process = config.optional.sitemap_urls.clone
      process_sitemaps( sitemaps_to_process, collected_urls )
      Log.logger.info("Located urls\n#{collected_urls.join("\n")}")
      collected_urls
    end
  end

private

  def self.process_sitemaps( sitemaps_to_process, collected_urls )
    processed_sitemaps = []
    loop do
      sitemap_url = sitemaps_to_process.pop
      processs_sitemap( sitemap_url, sitemaps_to_process, processed_sitemaps, collected_urls )
      break if sitemaps_to_process.empty?
    end
  end

  def self.processs_sitemap( sitemap_url, sitemaps_to_process, processed_sitemaps, collected_urls )
    sitemap_content = get_sitemap_content( sitemap_url )
    processed_sitemaps << sitemap_url
    unless sitemap_content.nil?

      begin
        Log.logger.debug( "Sitemap sitemap_url=#{sitemap_url} contains\n#{sitemap_content}" )
        as_xml_doc = REXML::Document.new(sitemap_content)

        as_xml_doc.elements.each('sitemapindex/sitemap/loc') do |location_element|
          url = location_element.text
          # todo add code to reject sitemap urls if not in domains to be spidered and such
          sitemaps_to_process << url unless sitemaps_to_process.include?( url )
        end

        as_xml_doc.elements.each('sitemapindex/urlset/url/loc') do |location_element|
          url = location_element.text
          # todo add code to reject urls if not in domains to be spidered and such
          collected_urls << url unless collected_urls.include?( url )
        end

      rescue => ex
        Log.logger.error( "Error: sitemap_url=#{sitemap_url} contents could not be parsed as xml")
      end

    end
  end

  def self.get_sitemap_content( sitemap_url )
    begin
      agent = Mechanize.new do |a|
        a.agent.verify_mode = OpenSSL::SSL::VERIFY_NONE   #disabled SSL check
        a.agent.gzip_enabled = false                      #gzip seems flaky so disabled
      end
      #todo add the useragent from our config file...
      page = agent.get( sitemap_url, nil, nil, {} )
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