class Dashing.Number extends Dashing.Widget
  @accessor 'current', Dashing.AnimatedValue

  @accessor 'difference', ->
    if @get('last')
      last = parseInt(@get('last'))
      current = parseInt(@get('current'))
      if last != 0
        if (@get('showDifferenceAsPercentage'))
          diff = Math.abs(Math.round(((current - last) / (current + last) / 2) * 100))
        else
          diff = Math.abs(current - last)
        if diff != 0
          "#{diff}"
        else
          ""
    else
      ""

  @accessor 'arrow', ->
    if @get('last')
      diff = parseInt(@get('current')) - parseInt(@get('last'))
      if diff > 0
        'icon-arrow-up'
      else if diff < 0
        'icon-arrow-down'
      else
        'icon-minus'

  @wrapAccessor 'updatedAtMessage', (core) ->
    get: () ->
      console.log(@get('customUpdatedAt'))
      if (!@get('customUpdatedAt'))
        core.get.call(this)
      else
        updatedAt = @get('customUpdatedAt')
        timestamp = new Date(updatedAt)
        day = timestamp.getDate()
        month = timestamp.getMonth() + 1
        "Last updated #{day}/#{month}"

  onData: (data) ->
    if data.status
      # clear existing "status-*" classes
      $(@get('node')).attr 'class', (i,c) ->
        c.replace /\bstatus-\S+/g, ''
      # add new class
      $(@get('node')).addClass "status-#{data.status}"
