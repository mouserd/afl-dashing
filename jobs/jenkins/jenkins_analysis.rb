
def fetchAnalysisResults

  pmd = Jenkins.get_analysis_results("pmd", "CMS")
  findbugs = Jenkins.get_analysis_results("findbugs", "CMS")
  checkstyle = Jenkins.get_analysis_results("checkstyle", "CMS")

  send_event("findbugs", findbugs)
  send_event("pmd", pmd)
  send_event("checkstyle", checkstyle)

  send_event("findbugs-meter", value: findbugs["current"], previous: findbugs["last"])
  send_event("pmd-meter", value: pmd["current"], previous: pmd["last"])
  send_event("checkstyle-meter", value: checkstyle["current"], previous: checkstyle["last"])
end


# Always publish results on load.
# fetchAnalysisResults

# Then every 1 hour thereafter.
SCHEDULER.every "1h", :first_in => 0 do |job|
  fetchAnalysisResults
end

