class Dashing.MeterNumber extends Dashing.Widget

  @accessor 'value', Dashing.AnimatedValue

  constructor: ->
    super
    @observe 'value', (value) ->
      $(@node).find(".meter").val(value).trigger('change')

  @accessor 'difference', ->
    if @get('last')
      last = parseInt(@get('last'))
      current = parseInt(@get('value'))
      if last != 0
        if (@get('showDifferenceAsPercentage'))
          diff = Math.abs(Math.round(((current - last) / (current + last) / 2) * 100))
        else
          diff = Math.abs(current - last)
      if diff != 0
          if @get('showDifferenceAsPercentage')
            "#{diff}%"
          else
            "#{diff}"
        else
          ""
    else
      ""

  @accessor 'arrow', ->
    if @get('last')
      diff = parseInt(@get('value')) - parseInt(@get('last'))
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

  ready: ->
    meter = $(@node).find(".meter")
    meter.attr("data-bgcolor", meter.css("background-color"))
    meter.attr("data-fgcolor", meter.css("color"))
    meter.knob()
