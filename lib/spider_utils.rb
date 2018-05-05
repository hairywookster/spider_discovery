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
    if config.optional.domains_to_spider.empty?
      true
    else
      config.optional.domains_to_spider.each do |domain|
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

end