require 'open-uri'
require 'json'
require 'nokogiri'
require 'uri'

require_relative '../config.rb'

class JobQueue
  class << self
    config = Config.get

    CMS_INCOMPLETE_JOB_QUEUE_URL = config["cms"]["urls"]["incompleteJobQueue"]
    CMS_COMPLETE_JOB_QUEUE_URL = config["cms"]["urls"]["completeJobQueue"]
    CMS_JOB_QUEUE_STATS_URL = config["cms"]["urls"]["jobQueueStats"]

    def get_job_queue_stats()

      puts "[DEBUG] Fetching CMS JobQueue stats..."

      results = get_json(CMS_JOB_QUEUE_STATS_URL)
      puts "[DEBUG] results: #{results}"

      results
    end

    def get_complete_jobitems()

      puts "[DEBUG] Fetching CMS 'Complete' JobQueueItems..."

      results = get_json(CMS_COMPLETE_JOB_QUEUE_URL)
      puts "[DEBUG] results: #{results}"

      results
    end

    def get_incomplete_jobitems()

      puts "[DEBUG] Fetching CMS 'Incomplete' JobQueueItems..."

      results = get_json(CMS_INCOMPLETE_JOB_QUEUE_URL)
      puts "[DEBUG] results: #{results}"

      results
    end


    private

    def get_json(url)
      begin
        JSON.parse(open(URI.escape(url)).read)
      rescue OpenURI::HTTPError => e
        if e.message == '404 Not Found'
          puts "Encountered a 404 accessing #{url}, ignoring"
        else
          raise e
        end
      end
    end
  end
end
