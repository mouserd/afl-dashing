
def fetch_test_results

  # We have to remove the JS test results from the unit tests as jenkins currently collects these together.
  unit_test_results = Jenkins.get_test_results("CMS unit test numbers")
  js_unit_tests_results = Jenkins.get_js_test_results("CMS unit test numbers")

  unit_test_results["current"] -= js_unit_tests_results["current"]
  unit_test_results["last"] -= js_unit_tests_results["last"]

  puts "[DEBUG] Recalculated unit test results #{unit_test_results}"

  send_event('unit-test-count', unit_test_results)
  send_event('js-unit-test-count', js_unit_tests_results)
  send_event('integration-test-count', Jenkins.get_test_results("CMS integration test numbers"))
  send_event('bdd-test-count', Jenkins.get_bdd_test_results("CMS BDD"))
end


# Always publish results on load.
fetch_test_results

# Then every 12 hours thereafter.
SCHEDULER.every '12h' do
  fetch_test_results
end

