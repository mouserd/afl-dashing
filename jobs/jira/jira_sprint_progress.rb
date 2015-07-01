require 'jira'

config = Config.get

SCHEDULER.every "10m", :first_in => 0 do |job|
  client = JIRA::Client.new({
    :username => config["jira"]["username"],
    :password => config["jira"]["password"],
    :site => config["jira"]["url"],
    :auth_type => :basic,
    :context_path => ""
  })

  # TODO Refactor to move these into the Jira class where possible
  begin
    closed_points = client.Issue.jql(config["jira"]["queries"]["closedSprintStories"]).map{ |issue| issue.fields["customfield_10103"] }.reduce(:+) || 0
    total_points = client.Issue.jql(config["jira"]["queries"]["openSprintStories"]).map{ |issue| issue.fields["customfield_10103"] }.reduce(:+) || 0
  rescue JIRA::HTTPError => error
    puts error.code + " " + error.message
    puts error.response
  end

  if total_points == 0
    percentage = 0
    moreinfo = "No sprint currently in progress"
  else
    percentage = ((closed_points/total_points)*100).to_i
    moreinfo = "#{closed_points.to_i} / #{total_points.to_i}"
  end

  send_event("jira-sprint-progress", { value: percentage, max: 100, moreinfo: moreinfo })
end
