class ConfigValidator

  def self.validate_config_file( config_file )
    puts "Validating config held inside #{config_file}"

    collected_errors = []
    begin
      file_contents = File.read( config_file )
      json_obj      = JSON.parse( file_contents ).extend(Methodize)
      json_obj.to_json   #round trip check

      validate_log_level( json_obj, collected_errors )

      if collected_errors.empty?
        puts "Success: #{config_file} is valid"
      else
        puts "Error: #{config_file} is invalid"
        puts "Errors were\n#{collected_errors.join("\n")}"
      end
      json_obj
    rescue Exception => erd
      puts "Error: #{config_file} is invalid, it failed to parse as json"
      puts "#{erd.to_s}\n#{erd.backtrace.join("\n")}"
    end

  end

private

  def self.validate_log_level( json_obj, collected_errors )
    unless Log.valid_log_levels.include?( json_obj.log_level.to_sym )
      collected_errors << "Logging level in config file as key log_level=#{json_obj.log_level} is invalid, it must be one of #{Log.valid_log_levels.map {|x,y| x}.join(",")}"
    end
  end

end