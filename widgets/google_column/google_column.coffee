class Dashing.GoogleColumn extends Dashing.Widget

  @accessor 'current', ->
    return @get('displayedValue') if @get('displayedValue')
    points = @get('points')
    if points
      points[points.length - 1].y

  ready: ->
    container = $(@node).parent()
    # Gross hacks. Let's fix this.
    width = (Dashing.widget_base_dimensions[0] * container.data("sizex")) + Dashing.widget_margins[0] * 2 * (container.data("sizex") - 1)
    height = (Dashing.widget_base_dimensions[1] * container.data("sizey"))

    colors = null
    if @get('colors')
      colors = @get('colors').split(/\s*,\s*/)

    @chart = new google.visualization.ColumnChart($(@node).find(".chart")[0])
    @options =
      height: height
      width: width
      colors: colors
      seriesType:'bars'
      backgroundColor:
        fill:'transparent'
      isStacked: @get('is_stacked')
      legend:
        position: @get('legend_position')
      animation:
        duration: 1000,
        easing: 'out'
      tooltip:
        trigger:'none'
      enableInteractivity:'false'
      vAxis:
        gridlines:
          color: '#C8DAE9'
      annotations:
        textStyle:
          fontSize: @get('annotation_font_size')
          bold: 'true'
      hAxis:
        textStyle:
          fontSize: @get('axis_font_size')
      vAxis:
        textStyle:
          fontSize: @get('axis_font_size')

    if @get('points')
      @data = google.visualization.arrayToDataTable @get('points')
    else
      @data = google.visualization.arrayToDataTable []

    @chart.draw @data, @options

  onData: (data) ->
    if @chart
      @data = google.visualization.arrayToDataTable data.points
      @chart.draw @data, @options