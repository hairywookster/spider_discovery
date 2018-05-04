class ConfigValidator

  def self.init_config( config_file )
    config = ConfigValidator.validate_config_file( config_file )
    Log.init_logger config.log_level
    config
  end

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
      validate_delay_between_requests_in_milliseconds( json_obj, collected_errors )
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

  def self.validate_delay_between_requests_in_milliseconds( json_obj, collected_errors )
    unless json_obj.delay_between_requests_in_milliseconds.is_a?( Integer ) && json_obj.delay_between_requests_in_milliseconds >= 0
      collected_errors << "Delay between requests in milliseconds in config file as key delay_between_requests_in_milliseconds=#{json_obj.delay_between_requests_in_milliseconds} is invalid, it must be set to a positive integer"
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
        if domain_to_validate.blank?
          collected_errors << "Domains to spider in key domains_to_spider=#{json_obj.optional.domains_to_spider} is invalid, it must contain entries that are not blank"
        end
      end
    end
  end

  def self.validate_headers_for_requests( json_obj, collected_errors )
    validate_non_blank_key_values( json_obj.optional.headers_for_requests, collected_errors, 'headers_for_requests' )
  end

  def self.validate_cookies_for_requests( json_obj, collected_errors )
    validate_non_blank_key_values( json_obj.optional.cookies_for_requests, collected_errors, 'cookies_for_requests' )
  end

  def self.validate_non_blank_key_values( entries, collected_errors, config_field_name )
    unless entries.empty?
      entries.each do |key, value|
        if key.blank?
          collected_errors << "Key/Value in key #{config_field_name} key=#{key} value=#{value} is invalid, it must contain key/value pairs that are not blank"
        end
        if value.blank?
          collected_errors << "Key/Value in key #{config_field_name} key=#{key} value=#{value} is invalid, it must contain key/value pairs that are not blank"
        end
      end
    end
  end

  def self.validate_url_references( urls_to_validate, collected_errors, config_field_name )
    unless urls_to_validate.empty?
      urls_to_validate.each do |url_to_validate|
        if url_to_validate.blank?
          collected_errors << "Url in key #{config_field_name} url=#{url_to_validate} is invalid, it must not be blank"
        elsif !( url_to_validate.start_with?( 'http://' ) || url_to_validate.start_with?( 'https://' ) )
          collected_errors << "Url in key #{config_field_name} url=#{url_to_validate} is invalid, it should be a fully qualified domain starting with http:// or https://"
        end
      end
    end
  end

end