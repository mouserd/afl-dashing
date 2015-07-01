class Dashing.MeterNumber extends Dashing.Widget

  @accessor 'value', Dashing.AnimatedValue

  constructor: ->
    super
    @observe 'value', (value) ->
      $(@node).find(".meter").val(value).trigger('change')

  @accessor 'difference', ->
    if @get('previous')
      last = parseInt(@get('previous'))
      current = parseInt(@get('value'))
      if last != 0
        diff = Math.abs(current - last)
        if diff != 0
          "#{diff}"
        else
          ""
    else
      ""

  @accessor 'arrow', ->
    if @get('last')
      diff = parseInt(@get('value')) - parseInt(@get('previous'))
      if diff > 0
        'icon-arrow-up'
      else if diff < 0
        'icon-arrow-down'
      else
        'icon-minus'

  ready: ->
    meter = $(@node).find(".meter")
    meter.attr("data-bgcolor", meter.css("background-color"))
    meter.attr("data-fgcolor", meter.css("color"))
    meter.knob()
