$last = nil

def get_jira_backlog_ready_no_story_points
  config = Config.get

  results = Jira.sum_story_points_query("Backlog Ready Stories, No Points", config["jira"]["queries"]["backlogReadyNoPoints"])
  send_event("jira-backlog-ready-no-points", { current: results["count"], last: $last || results["count"] })

  results["count"]
end

# $last = get_jira_backlog_ready_no_story_points

SCHEDULER.every "30m", :first_in => 0 do |job|
  get_jira_backlog_ready_no_story_points
end
