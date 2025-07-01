require('./assets/lib/piety')($, document)

## CPU Usage Widget - Apple Style
colors =
  low: '#34C759'
  med: '#FF9F0A'
  high: '#FF453A'
  back: 'rgba(255,255,255,0.15)'

## Chart configuration
chartWidth = 16
chartType = 'donut'

## Relative positioning from the background widget
relativeLeft = -185
relativeTop = -9

refreshFrequency: 2000

command: "ps -A -o %cpu | awk '{s+=$1} END {printf(\"%.0f\",s/8);}'"

render: (output) ->
  """
  <div class="cpu-widget">
    <span class="chart"></span>
    <span class="label">#{output}%</span>
  </div>
  """

update: (output, el) ->
  cpu = Number(output)
  fill = colors.low
  fill = colors.med if cpu > 50
  fill = colors.high if cpu > 80

  $(".cpu-widget .label", el).text("#{cpu}%")
  $(".cpu-widget .chart", el).text("#{cpu}/100").peity chartType,
    fill: [fill, colors.back]
    width: chartWidth
    height: chartWidth

afterRender: (el, dispatch) ->
  config_path = "$PWD/mini-system-charts.widget/config.json"
  @run "cat \"#{config_path}\"", (err, output) ->
    if err
      console.error "CPU Widget Error: Could not read config.json: #{err}"
      return
    try
      config = JSON.parse(output)
      # Use calc() to combine percentage from config and pixels from relative offset
      newLeft = "calc(#{config.baseLeft} + #{relativeLeft}px)"
      newTop = "calc(#{config.baseTop} + #{relativeTop}px)"

      $(el).css({
        top: newTop,
        left: newLeft
      })
    catch e
      console.error "CPU Widget Error: Could not parse config.json: #{e}"

style: """
  display: flex
  align-items: center
  gap: 6px
  color: rgba(255,255,255,0.9)
  font: 600 12px -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif
  -webkit-font-smoothing: antialiased
  .cpu-widget
    display: flex
    align-items: center
    gap: 6px
  .chart
    display: block
    line-height: 1
  .label
    font-variant-numeric: tabular-nums
"""
