require 'open-uri'
require 'json'
require 'nokogiri'
require 'uri'

class Jenkins
  class << self
    config = Config.get

    JENKINS_JOB_BUILDS_URL = config["jenkins"]["urls"]["jobBuilds"]
    JENKINS_TEST_RESULTS_URL = config["jenkins"]["urls"]["testResults"]
    JENKINS_BDD_RESULTS_URL = config["jenkins"]["urls"]["bddTestResults"]
    JENKINS_JS_UNIT_TEST_RESULTS_URL = config["jenkins"]["urls"]["jsTestResults"]

    JENKINS_ANALYSIS_RESULTS_URL = config["jenkins"]["urls"]["analysisResults"]

    BASIC_AUTH = { http_basic_authentication: [config["jenkins"]["username"], config["jenkins"]["password"]] }

    def get_test_results(jenkinsJobName)

      puts "[DEBUG] Fetching Jenkins '#{jenkinsJobName}' test results..."

      results = {}
      builds = get_jenkins_builds(jenkinsJobName)

      if builds.length > 0
        results["current"] = get_jenkins_json_metric(JENKINS_TEST_RESULTS_URL % [jenkinsJobName, builds[0]["number"]], "totalCount")
        if builds.length > 1
          results["last"] = get_jenkins_json_metric(JENKINS_TEST_RESULTS_URL % [jenkinsJobName, builds[1]["number"]], "totalCount")
        end
      end

      puts "[DEBUG] results: #{results}"

      results
    end

    def get_js_test_results(jenkinsJobName)

      puts "[DEBUG] Fetching Jenkins '#{jenkinsJobName}' JS test results..."

      results = {}
      builds = get_jenkins_builds(jenkinsJobName)

      if builds.length > 0
        results["current"] = get_jenkins_json_metric(JENKINS_JS_UNIT_TEST_RESULTS_URL % [jenkinsJobName, builds[0]["number"]], "passCount")
        if builds.length > 1
          results["last"] = get_jenkins_json_metric(JENKINS_JS_UNIT_TEST_RESULTS_URL % [jenkinsJobName, builds[1]["number"]], "passCount")
        end
      end

      puts "[DEBUG] results: #{results}"

      results
    end

    def get_bdd_test_results(jenkinsJobName)

      puts "[DEBUG] Fetching Jenkins '#{jenkinsJobName}' BDD test results..."

      results = {}
      builds = get_jenkins_builds(jenkinsJobName)

      if builds.length > 0
        doc = Nokogiri::HTML(open(URI.escape(JENKINS_BDD_RESULTS_URL % [jenkinsJobName, builds[0]["number"]]), BASIC_AUTH))
        results["current"] = doc.css('#stats-total-scenarios').text

        if builds.length > 1
          doc = Nokogiri::HTML(open(URI.escape(JENKINS_BDD_RESULTS_URL % [jenkinsJobName, builds[1]["number"]]), BASIC_AUTH))
          results["last"] = doc.css('#stats-total-scenarios').text
        end
      end

      puts "[DEBUG] results: #{results}"

      results
    end

    def get_analysis_results(analysisType, jenkinsJobName, buildNo = "lastSuccessfulBuild")
      puts "[DEBUG] Fetching Jenkins '#{jenkinsJobName}' #{analysisType} results..."
      results = {}

      data = get_jenkins_json(JENKINS_ANALYSIS_RESULTS_URL % [jenkinsJobName, buildNo, analysisType])
      results["current"] = data["numberOfWarnings"]
      results["last"] = data["numberOfWarnings"] - data["numberOfFixedWarnings"] - data["numberOfNewWarnings"]

      puts "[DEBUG] results: #{results}"

      results
    end

    def get_historic_analysis_results(analysisType, jenkinsJobName)
      puts "[DEBUG] Fetching Jenkins '#{jenkinsJobName}' historic #{analysisType} results..."
      results = []

      builds = get_jenkins_builds(jenkinsJobName)

      x = 0
      builds.each do | build |
        historic_metric = get_jenkins_json_metric(JENKINS_ANALYSIS_RESULTS_URL % [jenkinsJobName, build["number"], analysisType],
                                          "numberOfWarnings")
        if historic_metric
          results << { x: x+=1, y: historic_metric }
        end
      end

      puts "[DEBUG] results: #{results}"

      results
    end

    private

    def get_jenkins_json(url)
      begin
        JSON.parse(open(URI.escape(url), BASIC_AUTH).read)
      rescue OpenURI::HTTPError => e
        if e.message == '404 Not Found'
          puts "Encountered a 404 accessing #{url}, ignoring"
        else
          raise e
        end
      end
    end

    def get_jenkins_json_metric(url, metricName)

      json = get_jenkins_json(url)
      if json
        return json[metricName]
      end

      nil
    end

    def get_jenkins_builds(jenkinsJobName)


      url = JENKINS_JOB_BUILDS_URL % [jenkinsJobName]
      builds = JSON.parse(open(URI.escape(url), BASIC_AUTH).read)["builds"]

      # Filter only for successful builds.
      builds.select { |build| build["result"] == "SUCCESS" }
    end
  end
end
