require 'net/http'
require 'open-uri'
require 'json'
require 'nokogiri'
require 'uri'

class RateYourDay
  class << self
    config = Config.get

    RATE_YOUR_DAY_AUTH_URL = config["rateYourDay"]["urls"]["authUrl"]
    RATE_YOUR_DAY_SUMMARY_URL = config["rateYourDay"]["urls"]["summaryUrl"]

    RATE_YOUR_DAY_AUTH_USERNAME = config["rateYourDay"]["auth"]["username"]
    RATE_YOUR_DAY_AUTH_PASSWORD = config["rateYourDay"]["auth"]["password"]
    RATE_YOUR_DAY_AUTH_GRANT_TYPE = config["rateYourDay"]["auth"]["grantType"]

    DAYS_IN_WEEK = 5  # The API records only days that ratings were made (i.e. not weekends/public holidays etc)
                      # , so we're really just getting the last 5 "working days" of results.

    def get_weekly_results()

      puts "[DEBUG] Fetching RateYourDay test results..."

      results = {}
      ryd_results = get_rate_your_day_summary
      if ryd_results.length > DAYS_IN_WEEK
        ryd_results = ryd_results.drop(ryd_results.size - DAYS_IN_WEEK)
      end

      results['totalGood'] = 0
      results['totalMeh'] = 0
      results['totalBad'] = 0

      ryd_results.each do |ryd_result|
        results['totalGood'] += ryd_result['TotalGood']
        results['totalMeh'] += ryd_result['TotalMeh']
        results['totalBad'] += ryd_result['TotalBad']
      end

      puts "[DEBUG] results: good=#{results['totalGood']}, meh=#{results['totalMeh']}, bad=#{results['totalBad']}"

      results
    end

    private

    def get_rate_your_day_summary()

      params = {
          "grant_type" => RATE_YOUR_DAY_AUTH_GRANT_TYPE,
          "username" => RATE_YOUR_DAY_AUTH_USERNAME,
          "password" => RATE_YOUR_DAY_AUTH_PASSWORD
      }
      auth_response =  JSON.parse(Net::HTTP.post_form(URI.parse(RATE_YOUR_DAY_AUTH_URL), params).body)
      access_token = auth_response['access_token']

      JSON.parse(open(RATE_YOUR_DAY_SUMMARY_URL, { "Authorization" => "Bearer #{access_token}" }).read)
    end
  end
end
