
def fetch_test_results

  config = Config.get

  send_event('unit-test-count', Jenkins.get_test_results(config["jenkins"]["jobs"]["unitTests"]))
  send_event('js-unit-test-count', Jenkins.get_js_test_results(config["jenkins"]["jobs"]["jsUnitTests"]))
  send_event('integration-test-count', Jenkins.get_test_results(config["jenkins"]["jobs"]["integrationTests"]))
  send_event('bdd-test-count', Jenkins.get_bdd_test_results(config["jenkins"]["jobs"]["bddTests"]))
end

# Always publish results on load.
# fetch_test_results

# Then every 12 hours thereafter.
SCHEDULER.every '12h', :first_in => 0 do |job|
  fetch_test_results
end

