$last = nil

def get_jira_open_defects_count
  # TODO Create class to wrap YAML creation and error handling...
  config = YAML.load_file(File.join(Dir.pwd, "application.yml"))

  results = Jira.sum_story_points_query(config["jira"]["queries"]["openDefects"])
  send_event("jira-open-defects", { current: results["count"], last: $last || results["count"] })

  results["count"]
end

$last = get_jira_open_defects_count

SCHEDULER.every "5s" do
  get_jira_open_defects_count
end
