$last = nil

def get_jira_backlog_ready_story_points
  config = Config.get

  results = Jira.sum_story_points_query("Backlog Ready Stories", config["jira"]["queries"]["backlogReadyStories"])
  send_event("jira-backlog-ready-points", { current: results["storyPoints"], last: $last || results["storyPoints"] })

  results["storyPoints"]
end

# $last = get_jira_backlog_ready_story_points

SCHEDULER.every "30m", :first_in => 0 do |job|
  get_jira_backlog_ready_story_points
end
