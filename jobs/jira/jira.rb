require 'jira'

class Jira

  class << self
    config = Config.get
    @@client = JIRA::Client.new({
        :username => config["jira"]["username"],
        :password => config["jira"]["password"],
        :site => config["jira"]["url"],
        :auth_type => :basic,
        :context_path => ""
    })
    @@storyPointsFieldKey = config["jira"]["elements"]["storyPointFieldId"]

    @@query_options = {
        :start_at => 0,
        :max_results => 1000
    }

    def sum_story_points_query(type, query)

      puts "[DEBUG] Fetching Jira '#{type}' query results..."

      results = {}
      query_results = []
      begin
        query_results = @@client.Issue.jql(query, @@query_options)
      rescue JIRA::HTTPError => error
        puts error.code + " " + error.message
        puts error.response
      end

      results["storyPoints"] = query_results.map { |issue| issue.fields[@@storyPointsFieldKey] || 0 }.reduce(:+) || 0
      results["count"] = query_results.length

      puts "[DEBUG] results: #{results}"

      results
    end


    private

  end
end
