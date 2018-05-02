class ConfigValidator

  def self.validate_all_json_config_files( config_file )
    puts "Validating config held inside #{config_file}"

    begin
      file_contents = File.read( config_file )
      json_obj      = JSON.parse( file_contents )
      json_obj.to_json   #round trip check
      puts "Success: #{config_file} is valid"
    rescue Exception => erd
      puts "Error: #{config_file} is invalid"
      #error was #{erd.to_s}\n#{erd.backtrace.join("\n")}
    end

  end

end