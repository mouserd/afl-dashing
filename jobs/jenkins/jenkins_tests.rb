
def fetch_test_results

  # The names of these jobs should be moved out to configuration!
  unit_test_results = Jenkins.get_test_results("CMS unit test numbers")
  integration_test_results = Jenkins.get_test_results("CMS integration test numbers")
  js_unit_tests_results = Jenkins.get_test_results("CMS unit test numbers - JS")

  send_event('unit-test-count', unit_test_results)
  send_event('js-unit-test-count', js_unit_tests_results)
  send_event('integration-test-count', integration_test_results)
  send_event('bdd-test-count', Jenkins.get_bdd_test_results("CMS BDD"))
end

# Always publish results on load.
# fetch_test_results

# Then every 12 hours thereafter.
SCHEDULER.every '12h', :first_in => 0 do |job|
  fetch_test_results
end

