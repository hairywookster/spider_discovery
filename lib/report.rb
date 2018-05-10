class Report

  FAILED = 'FAILED'

  def self.emit_reports( urls_visited_results, results_folder )
    Log.logger.info( "Spidering completed, generating reports" )
    total = urls_visited_results.size
    successes = urls_visited_results.select {|k, response_code| 200.eql?( response_code ) }
    errors = urls_visited_results.select {|k, response_code| !200.eql?( response_code ) }
    total_success = successes.size
    total_errors = total - total_success
    percent_success = ( (total_success.to_f / total.to_f) * 100 ).to_i
    percent_errors = 100.to_f - percent_success
    emit_console_report( total, total_success, percent_success, total_errors, percent_errors )
    emit_json_report( results_folder, urls_visited_results, total, total_success, percent_success, total_errors, percent_errors )
    emit_html_report( results_folder, urls_visited_results, total, total_success, percent_success, total_errors, percent_errors, successes, errors )
  end

private
  
  def self.emit_console_report( total, total_success, percent_success, total_errors, percent_errors )
    Log.logger.info( '-----------------------------------------------'.colorize(:light_yellow) )
    Log.logger.info( 'Summary'.colorize(:light_yellow) )
    Log.logger.info( '-----------------------------------------------'.colorize(:light_yellow) )
    Log.logger.info( "Total       = #{total}".colorize(:light_yellow) )
    Log.logger.info( "Successes   = #{total_success} (#{percent_success}%)".colorize(:light_green) )
    unless total_errors == 0
      Log.logger.info( "Errors      = #{total_errors} (#{percent_errors}%)".colorize(:light_magenta) )
    end
  end

  def self.emit_json_report( results_folder, urls_visited_results, total, total_success, percent_success, total_errors,
                             percent_errors )
    result = {
        :total_urls => total,
        :total_success => total_success,
        :percent_success => percent_success,
        :total_errors => total_errors,
        :percent_errors => percent_errors,
        :url_results => urls_visited_results
    }
    File.open("#{results_folder}/results.json", "w") do |f|
      f.puts( JSON.pretty_generate( result ) )
    end
  end

  def self.emit_html_report( results_folder, urls_visited_results, total, total_success, percent_success, total_errors,
                             percent_errors, successes, errors )
    random_failure_word = 'borked'   #todo random wordage
    #note all the values passed into this method are used via the binding object when the template gets rendered
    File.open("#{results_folder}/results.html", "w") do |file|
      file.puts ERB.new(File.read("#{File.dirname(__FILE__)}/html_report_template.html.erb")).result( binding )
    end
  end

end