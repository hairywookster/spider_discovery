class ConfigValidator

  def self.validate_config_file( config_file )
    puts "Validating config held inside #{File.expand_path(config_file)}"

    collected_errors = []
    begin
      file_contents = File.read( config_file )
      json_obj      = JSON.parse( file_contents ).extend(Methodize)
      json_obj.to_json   #round trip check

      validate_log_level( json_obj, collected_errors )
      validate_urls_to_spider( json_obj, collected_errors )
      validate_urls_to_ignore( json_obj, collected_errors )
      validate_sitemap_urls( json_obj, collected_errors )
      validate_domains_to_spider( json_obj, collected_errors )
      validate_user_agent_for_requests( json_obj, collected_errors )
      validate_headers_for_requests( json_obj, collected_errors )
      validate_cookies_for_requests( json_obj, collected_errors )

      if collected_errors.empty?
        puts "Success: #{config_file} is valid"
      else
        puts "Error: config is invalid"
        puts collected_errors.join("\n")
      end
      json_obj
    rescue Exception => erd
      puts "Error: config is invalid, it was not valid json, if in doubt google jsonlint :)"
      puts "#{erd.to_s}\n#{erd.backtrace.join("\n")}"
    end

  end

private

  def self.validate_log_level( json_obj, collected_errors )
    unless Log.valid_log_levels.include?( json_obj.log_level.to_sym )
      collected_errors << "Logging level in config file as key log_level=#{json_obj.log_level} is invalid, it must be one of #{Log.valid_log_levels.map {|x,y| x}.join(",")}"
    end
  end

  def self.validate_urls_to_spider( json_obj, collected_errors )
    if json_obj.urls_to_spider.empty?
      collected_errors << "Urls to spider in config file as key urls_to_spider=#{json_obj.urls_to_spider} is invalid, it must contain a least one fully qualified url"
    end
    validate_url_references( json_obj.urls_to_spider, collected_errors, 'urls_to_spider' )
  end

  def self.validate_user_agent_for_requests( json_obj, collected_errors )
    if json_obj.user_agent_for_requests.blank?
      collected_errors << "User agent for requests in config file as key user_agent_for_requests=#{json_obj.user_agent_for_requests} is invalid, it must contain a non blank string"
    end
  end

  def self.validate_urls_to_ignore( json_obj, collected_errors )
    validate_url_references( json_obj.optional.urls_to_ignore, collected_errors, 'urls_to_ignore' )
  end

  def self.validate_sitemap_urls( json_obj, collected_errors )
    validate_url_references( json_obj.optional.sitemap_urls, collected_errors, 'sitemap_urls' )
  end

  def self.validate_domains_to_spider( json_obj, collected_errors )
    unless json_obj.optional.domains_to_spider.empty?
      json_obj.optional.domains_to_spider.each do |domain_to_validate|
        #todo check it conforms to reg expression for sane domains or simple check of not blank and no spaces
      end
    end
  end

  def self.validate_headers_for_requests( json_obj, collected_errors )
    #todo check headers and values are sane
  end

  def self.validate_cookies_for_requests( json_obj, collected_errors )
    #todo check cookies names and values are sane
  end

  def self.validate_url_references( urls_to_validate, collected_errors, config_field_name )
    unless urls_to_validate.empty?
      urls_to_validate.each do |url_to_validate|
        #todo check it conforms to reg expression for urls
      end
    end
  end

end