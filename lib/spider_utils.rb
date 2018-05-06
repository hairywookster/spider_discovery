class SpiderUtils

  def self.url_should_be_included?( url, urls, config )
    unless urls.include?( url )
      if should_spider_domain?( url, config ) &&
          should_spider_url?( url, config )
        return true
      end
    end
    false
  end

  def self.should_spider_domain?( url, config )
    if config.domains_to_spider.empty?
      true
    else
      config.domains_to_spider.each do |domain|
        if url.include?( domain )
          return true
        end
      end
      false
    end
  end

  def self.should_spider_url?( url, config )
    if config.optional.urls_to_ignore.empty?
      true
    else
      config.optional.urls_to_ignore.each do |url_to_ignore|
        if url.include?( url_to_ignore )
          return false
        end
      end
      true
    end
  end

  def self.build_headers( config )
    headers = config.optional.headers_for_requests.clone
    #https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/User-Agent
    headers[ 'User-Agent' ] = config.user_agent_for_requests
    #https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cookie
    headers[ 'Cookie' ] = config.optional.cookies_for_requests.map {|k,v| "#{k}=#{v}"}.join('; ')
    headers
  end

end