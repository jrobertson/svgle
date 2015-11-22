# Introducing the Svgle (SVG + Rexle) gem

    require 'svgle'

    s =<<SVG
    <svg width="400" height="110">
      <g id="group1" fill="red">
        <line x1="0" y1="0" x2="200" y2="200" style="stroke:rgb(255,0,0);stroke-width:2" />
      </g>
    </svg>
    SVG


    doc = Svgle.new(s)
    line = doc.root.element('g').element('line')
    line.class #=> Svgle::Line

    line.x1 #=> "0"
    lines.x1 = 44
    line.x1 #=> "44"

## Resources

* svgle https://rubygems.org/gems/svgle

svgle svg rexle
