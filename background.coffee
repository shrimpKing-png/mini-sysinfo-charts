refreshFrequency: false

render: ->
  """
  """

style: """
  /* Styles for the background element */
  height: 23px
  width: 400px
  background: linear-gradient(180deg, rgba(0,0,0,0.15) 0%, rgba(0,0,0,0.25) 100%)
  backdrop-filter: blur(20px)
  -webkit-backdrop-filter: blur(20px)
  border: 1px solid rgba(255,255,255,0.1)
  border-radius: 6px
  z-index: -1
"""

afterRender: (el, dispatch) ->
  config_path = "$PWD/mini-system-charts.widget/config.json"
  @run "cat \"#{config_path}\"", (err, output) ->
    if err
      console.error "Background Widget Error: Could not read config.json: #{err}"
      return

    try
      config = JSON.parse(output)
      $(el).css({
        top: config.baseTop,
        left: config.baseLeft,
        transform: 'translate(-50%, -50%)'  # This ensures true centering
      })
    catch e
      console.error "Background Widget Error: Could not parse config.json: #{e}"
