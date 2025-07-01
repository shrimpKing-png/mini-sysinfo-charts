require('./assets/lib/piety')($, document)

## Disk Usage Widget - Apple Style
colors =
  low: '#34C759'
  med: '#FF9F0A'
  high: '#FF453A'
  back: 'rgba(255,255,255,0.15)'

## Chart configuration
chartWidth = 16
chartType = 'donut'

## Relative positioning from the background widget
# original disk.left (152px) - original background.left (8px) = 144px
relativeLeft = -55
# original disk.top (6px) - original background.top (2px) = 4px
relativeTop = -9

refreshFrequency: 20000

command: "df -H | grep '/dev/' | while read -r line; do fs=$(echo $line | awk '{print $1}'); name=$(diskutil info $fs | grep 'Volume Name' | awk '{print substr($0, index($0,$3))}'); echo $(echo $line | awk '{print $2, $3, $4, $5}') $(echo $name | awk '{print substr($0, index($0,$1))}'); done"

render: ()-> """
  <div class="disk-widget">
    <span class="chart"></span>
    <span class="label"></span>
  </div>
"""

update: (output, el) ->
  disk = output.split('\n')[0]
  return unless disk
  args = disk.split(' ').filter((arg) -> arg.length > 0)
  [total, _, free, pctg] = args
  totalNum = parseFloat(total.replace(/[^\d.]/g, ''))
  freeNum = parseFloat(free.replace(/[^\d.]/g, ''))
  usedPct = Math.round((1 - freeNum / totalNum) * 100)
  fill = colors.low
  fill = colors.med if usedPct > 50
  fill = colors.high if usedPct > 80

  $(".disk-widget .label", el).text("#{usedPct}%")
  $(".disk-widget .chart", el).text("#{usedPct}/100").peity chartType,
    fill: [fill, colors.back]
    width: chartWidth
    height: chartWidth

afterRender: (el, dispatch) ->
  config_path = "$PWD/mini-system-charts.widget/config.json"
  # The path variable is now wrapped in quotes to handle spaces
  @run "cat \"#{config_path}\"", (err, output) ->
    if err
      console.error "Disk Widget Error: Could not read config.json: #{err}"
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
      console.error "Disk Widget Error: Could not parse config.json: #{e}"

style: """
  display: flex
  align-items: center
  gap: 6px
  color: rgba(255,255,255,0.9)
  font: 600 12px -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif
  -webkit-font-smoothing: antialiased
  .disk-widget
    display: flex
    align-items: center
    gap: 6px
  .chart
    display: block
    line-height: 1
  .label
    font-variant-numeric: tabular-nums
"""
