
def fetchTestResults
  send_event('unit-test-count', Jenkins.get_test_results("CMS unit test numbers"))
  send_event('js-unit-test-count', Jenkins.get_js_test_results("CMS unit test numbers"))
  send_event('integration-test-count', Jenkins.get_test_results("CMS integration test numbers"))
  send_event('bdd-test-count', Jenkins.get_bdd_test_results("CMS BDD"))
end


# Always publish results on load.
fetchTestResults

# Then every 12 hours thereafter.
SCHEDULER.every '12h' do
  fetchTestResults
end

