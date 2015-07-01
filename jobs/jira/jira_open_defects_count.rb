$last = nil

def get_jira_open_defects_count
  config = Config.get

  results = Jira.sum_story_points_query("Open Defects", config["jira"]["queries"]["openDefects"])
  send_event("jira-open-defects", { current: results["count"], last: $last || results["count"] })

  results["count"]
end

$last = get_jira_open_defects_count

SCHEDULER.every "5s" do
  get_jira_open_defects_count
end
