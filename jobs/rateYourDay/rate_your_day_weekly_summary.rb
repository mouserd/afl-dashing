
SCHEDULER.every "12h", :first_in => 0 do |job|

  results = RateYourDay.get_weekly_results

  send_event('rate-your-day',
             points: [
                 ["", "", {role: "style"}, {role: "annotation" }],
                 ["Happy", results['totalGood'] , "#96BF48", results['totalGood']],
                 ["Meh",  results['totalMeh'], "#C0C0C0", results['totalMeh']],
                 ["Sad", results['totalBad'], "#BF4848", results['totalBad']]
             ],)
end