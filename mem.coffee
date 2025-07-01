require('./assets/lib/piety')($, document)

## Memory Usage Widget - Apple Style
colors =
  low: '#34C759'
  med: '#FF9F0A'
  high: '#FF453A'
  back: 'rgba(255,255,255,0.15)'

## Chart configuration
chartWidth = 16
chartType = 'donut'

## Relative positioning from the background widget
# original mem.left (82px) - original background.left (8px) = 74px
relativeLeft = -120
# original mem.top (6px) - original background.top (2px) = 4px
relativeTop = -9

refreshFrequency: 2000

command: """vm_stat | perl -ne '/page size of (\\d+)/ and $size=$1; /Pages\\s+([^:]+)[^\\d]+(\\d+)/ and printf("%s:%i,", "$1", $2 * $size / 1048576);'"""

render: (output) ->
  """
  <div class="mem-widget">
    <span class="chart"></span>
    <span class="label"></span>
  </div>
  """

update: (output, el) ->
  mem = {}
  output.split(',').forEach (item)->
    [key, value] = item.replace(' ', '_').split(':')
    mem[key] = Number(value) if value
  available = (mem.free || 0) + (mem.inactive || 0)
  total = available + (mem.active || 0) + (mem.wired_down || 0)
  usedPct = Math.round(((total - available) / total) * 100)
  fill = colors.low
  fill = colors.med if usedPct > 50
  fill = colors.high if usedPct > 80

  $(".mem-widget .label", el).text("#{usedPct}%")
  $(".mem-widget .chart", el).text("#{usedPct}/100").peity chartType,
    fill: [fill, colors.back]
    width: chartWidth
    height: chartWidth

afterRender: (el, dispatch) ->
  config_path = "$PWD/mini-system-charts.widget/config.json"
  # The path variable is now wrapped in quotes to handle spaces
  @run "cat \"#{config_path}\"", (err, output) ->
    if err
      console.error "Memory Widget Error: Could not read config.json: #{err}"
      return
    try
      config = JSON.parse(output)
      # Use calc() to combine percentage from config and pixels from relative offset
      newLeft = "calc(#{config.baseLeft} + #{relativeLeft}px)"
      newTop = "calc(#{config.baseTop} + #{relativeTop}px)"

      # Correctly apply the calc() string without adding an extra "px"
      $(el).css({
        top: newTop,
        left: newLeft
      })
    catch e
      console.error "Memory Widget Error: Could not parse config.json: #{e}"

style: """
  display: flex
  align-items: center
  gap: 6px
  color: rgba(255,255,255,0.9)
  font: 600 12px -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif
  -webkit-font-smoothing: antialiased
  .mem-widget
    display: flex
    align-items: center
    gap: 6px
  .chart
    display: block
    line-height: 1
  .label
    font-variant-numeric: tabular-nums
    min-width: 28px
"""
