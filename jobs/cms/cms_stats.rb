require 'date'
require_relative '../utils.rb'

def to_friendly_job_state(jobState)
  case jobState
    when "OPEN"
      'Creating'
    when "INITIALIZED"
      'Initialised'
    when "INPROCESS"
      'Processing'
    when "WFCOMPLETED"
      'Processed'
    when "DPCOMPLETED", "DPSUCCEEDED"
      'Complete'
    when "DPFAILED"
      'Failed'
    else
      'Unknown'
  end
end

headingRows = [
    {
        # style: 'color:#888;background-color:red;',
        class: 'right',
        cols: [
            { value: 'Site', class: 'left'},
            { value: 'Type', class: 'left'},
            { value: 'Status', style: 'text-align:center;'},
            { value: 'Published By', style: 'text-align:center;'},
            { value: 'Created', style: 'text-align:center;'},
            { value: '# Items', style: 'text-align:center;'},
            { value: 'Duration'}
        ]
    }
]

def fetch_complete_job_queue_items(headingRows)

  completeJobQueueItems = JobQueue.get_complete_jobitems

  dataRows = []
  (completeJobQueueItems).each do |item|
    dataRows << { cols: [
        {value: item['siteName'], class: 'left'},
        {value: item['jobType'], class: 'left'},
        {value: to_friendly_job_state(item['jobState'])},
        {value: item['requestor']},
        {value: Time.at(item['createdDate'] / 1000).strftime("%d-%b-%y %H:%M:%S")},
        {value: item['publishedItemCount']},
        {value: to_friendly_duration(item['processingTimeMillis']), class: 'right'},
    ]
    }
  end

  send_event('completed-jobs-detail', { hrows: headingRows, rows: dataRows } )
end

def fetch_incomplete_job_queue_items(headingRows)

  incompleteJobQueueItems = JobQueue.get_incomplete_jobitems

  dataRows = []
  (incompleteJobQueueItems).each_with_index do |item, index|

    cssClass = (index == incompleteJobQueueItems.size - 1 ? 'current' : '')
    dataRows << { cols: [
        {value: item['siteName'], class: "left #{cssClass}"},
        {value: item['jobType'], class: "left #{cssClass}"},
        {value: to_friendly_job_state(item['jobState']), class: "#{cssClass}"},
        {value: item['requestor'], class: "#{cssClass}"},
        {value: Time.at(item['createdDate'] / 1000).strftime("%d-%b-%y %H:%M:%S"), class: "#{cssClass}"},
        {value: item['publishedItemCount'], class: "#{cssClass}"},
        {value: to_friendly_duration(item['processingTimeMillis']), class: "right #{cssClass}"}
      ]
    }
  end

  completeJobQueueItems = JobQueue.get_complete_jobitems

  (completeJobQueueItems).each do |item|
    dataRows << { cols: [
        {value: item['siteName'], class: 'left'},
        {value: item['jobType'], class: 'left'},
        {value: to_friendly_job_state(item['jobState'])},
        {value: item['requestor']},
        {value: Time.at(item['createdDate'] / 1000).strftime("%d-%b-%y %H:%M:%S")},
        {value: item['publishedItemCount']},
        {value: to_friendly_duration(item['processingTimeMillis']), class: 'right'},
    ]
    }
  end

  send_event('jobs-detail', { hrows: headingRows, rows: dataRows } )

  # dataRows = [
  #
  #     { cols: [ {class: 'left', value: 'cell11'}, {value: 'value' + rand(5).to_s}, {class: 'right', value: rand(5)}, {class: 'right', value: rand(5)} ]},
  #     { cols: [ {class: 'left', value: 'cell21'}, {value: 'value' + rand(5).to_s}, {class: 'right', value: rand(5)}, {class: 'right', value: rand(5)} ]},
  #     { cols: [ {class: 'left', value: 'cell31'}, {value: 'value' + rand(5).to_s}, {class: 'right', value: rand(5)}, {class: 'right', value: rand(5)} ]},
  #     { cols: [ {class: 'left', value: 'cell41'}, {value: 'value' + rand(5).to_s}, {colspan: 2, class: 'right', value: rand(5)} ]}
  # ]


end

def fetch_job_queue_stats(lastJobQueueStats)
  jobQueueStats = JobQueue.get_job_queue_stats

  send_event('publish-job-count', {current: jobQueueStats['publishJobCount'] + 22, last: lastJobQueueStats['publishJobCount'] })
  send_event('average-publish-time', {current: to_friendly_duration(jobQueueStats['avgProcessingTimeMillis'] + 124),
                                      last: to_friendly_duration(lastJobQueueStats['avgProcessingTimeMillis'])})
  # send_event('hpd-dependencies-count', {current: jobQueueStats['hpdDependencyCount'] })

  jobQueueStats
end

# SCHEDULER.every '10s', :first_in => 0 do |job|
#   fetch_complete_job_queue_items(headingRows)
#   fetch_incomplete_job_queue_items(headingRows)
#
#   lastJobQueueStats = fetch_job_queue_stats(lastJobQueueStats || {})
# end
