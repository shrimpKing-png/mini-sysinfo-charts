require('./assets/lib/piety')($, document)

## Network Usage Widget - Apple Style
colors =
  download: '#34C759'
  upload: '#007AFF'
  back: 'rgba(255,255,255,0.1)'

## Chart configuration
chartWidth = 32
chartHeight = 12
dataPointCount = 10
chartType = 'line'

## Relative positioning from the background widget
# original network.left (222px) - original background.left (8px) = 214px
relativeLeft = 5
# original network.top (6px) - original background.top (2px) = 4px
relativeTop = -8

## Data storage
valuesIn = (0 for i in [0..dataPointCount])
valuesOut = (0 for i in [0..dataPointCount])
chartIn = null
chartOut = null

refreshFrequency: 2000

command: """
if [ ! -e assets/network.sh ]; then
  "$PWD/mini-system-charts.widget/assets/network.sh"
else
  "$PWD/assets/network.sh"
fi
"""

render: () -> """
<div class='network-widget'>
  <div class='charts'>
    <div class='chart-container'><div class='chart-in'></div></div>
    <div class='chart-container'><div class='chart-out'></div></div>
  </div>
  <div class='speeds'></div>
</div>
"""

update: (output, el) ->
  if not chartIn
    chartIn = $(".chart-in", el).peity chartType,
      fill: colors.download, stroke: colors.download, strokeWidth: 1, width: chartWidth, height: chartHeight, min: 0
    chartOut = $(".chart-out", el).peity chartType,
      fill: colors.upload, stroke: colors.upload, strokeWidth: 1, width: chartWidth, height: chartHeight, min: 0

  @run @command, (err, output) ->
    [dataIn, dataOut] = (parseFloat(n) for n in output.split(" "))
    return if isNaN(dataIn) or isNaN(dataOut)
    valuesIn.push(dataIn); valuesIn.shift() if valuesIn.length > dataPointCount
    valuesOut.push(dataOut); valuesOut.shift() if valuesOut.length > dataPointCount
    chartIn.text(valuesIn.join(",")).change()
    chartOut.text(valuesOut.join(",")).change()
    formatSpeed = (bytes) ->
      kb = bytes / 1000
      if kb > 1000 then "#{Math.round(kb / 100) / 10}M" else "#{Math.round(kb * 10) / 10}k"
    $('.speeds', el).html "<span class='speed-down'><span class='arrow'>↓</span>#{formatSpeed(dataIn)}</span> <span class='speed-up'><span class='arrow'>↑</span>#{formatSpeed(dataOut)}</span>"

afterRender: (el, dispatch) ->
  config_path = "$PWD/mini-system-charts.widget/config.json"
  # The path variable is now wrapped in quotes to handle spaces
  @run "cat \"#{config_path}\"", (err, output) ->
    if err
      console.error "Network Widget Error: Could not read config.json: #{err}"
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
      console.error "Network Widget Error: Could not parse config.json: #{e}"

style: """
  display: flex
  align-items: center
  gap: 8px
  color: rgba(255,255,255,0.9)
  font: 600 12px -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif
  -webkit-font-smoothing: antialiased

  .network-widget
    display: flex
    align-items: center
    gap: 8px

  .charts
    display: flex
    gap: 4px
    position: relative
    top: 2px

  .speeds
    font-variant-numeric: tabular-nums
    min-width: 48px
    display: flex
    gap: 8px

  .speed-down, .speed-up
    display: flex
    align-items: center
    gap: 2px

  .speed-down .arrow
    color: #34C759

  .speed-up .arrow
    color: #007AFF
"""
