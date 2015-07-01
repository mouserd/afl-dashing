# points = Jenkins.get_historic_analysis_results("findbugs", "CMS")
# def fetchAnalysisResults(points)
#
#   last_x = points.last[:x]
#   points.shift
#   last_x += 1
#
#   points << { x: last_x, y: Jenkins.get_analysis_results("findbugs", "CMS") }
#
#   send_event('findbugs-graph', points: points)
# end
#
#
# # Always publish results on load.
# fetchAnalysisResults(points)
#
# # Then every 1 hour thereafter.
# SCHEDULER.every '1h' do
#   fetchAnalysisResults(points)
# end

