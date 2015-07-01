require 'jira'

class Jira

  class << self
    @@config = YAML.load_file(File.join(Dir.pwd, "application.yml"))
    @@client = JIRA::Client.new({
        :username => @@config["jira"]["username"],
        :password => @@config["jira"]["password"],
        :site => @@config["jira"]["url"],
        :auth_type => :basic,
        :context_path => ""
    })

    @@query_options = {
        :start_at => 0,
        :max_results => 1000
    }

    def sum_story_points_query(type, query)

      puts "[DEBUG] Fetching jira #{type} query story points and count..."

      results = {}
      query_results = []
      begin
        query_results = @@client.Issue.jql(query, @@query_options)
      rescue JIRA::HTTPError => error
        puts error.code + " " + error.message
        puts error.response
      end

      results["storyPoints"] = query_results.map { |issue| issue.fields["customfield_10103"] || 0 }.reduce(:+) || 0
      results["count"] = query_results.length

      puts "[DEBUG] results: #{results}"

      results
    end


    private

  end
end
