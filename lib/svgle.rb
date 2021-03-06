#!/usr/bin/env ruby

# file: svgle.rb

require 'domle'


# helpful SVG element references: 
#
#    * https://developer.mozilla.org/en-US/docs/Web/SVG/Element
#    * http://www.w3schools.com/svg/svg_reference.asp
#    * http://tutorials.jenkov.com/svg/svg-transformation.html#transformation-example

# hotspot related:
# http://stackoverflow.com/questions/481144/equation-for-testing-if-a-point-is-inside-a-circle
# http://stackoverflow.com/questions/7946187/point-and-ellipse-rotated-position-test-algorithm
# computational geometry - ruby http://sourceforge.net/projects/ruby-comp-geom/

DEFAULT_SVGLE_CSS = <<CSS

g  {background-color: orange}
svg {background-color: white}
rect {fill: yellow}
line, polyline {stroke: green; stroke-width: 3}
text {fill: red}

CSS



class Svgle < Domle

  
  class SvgElement < Element
    
    @attr_map = {}
    attr_reader :attr_map
    
    attr2_accessor *%i(stroke stroke-width)

    
  end  
  
  class Shape < SvgElement
    attr2_accessor *%i(fill)
  end
  
  class A < SvgElement
    # undecided how to implement this 
    #  see http://stackoverflow.com/questions/12422668/getting-xlinkhref-attribute-of-the-svg-image-element-dynamically-using-js-i
    #attr2_accessor *%i(href)
  end    
  
  class Circle < Shape
    attr2_accessor *%i(cx cy r)
    def boundary()
      [0,0,0,0]
    end    
  end

  class Ellipse < Shape
    attr2_accessor *%i(cx cy rx ry)
    def boundary()
      [0,0,0,0]
    end    
  end    

  class G < SvgElement
    attr2_accessor *%i(fill opacity)
    def boundary()
      [0,0,0,0]
    end    
  end

  class Line < SvgElement
    attr2_accessor *%i(x1 y1 x2 y2)
    
    def boundary()
      [0,0,0,0]
    end
  end
  
  class Image < SvgElement
    
    attr2_accessor *%i(x y width height xlink:href src)
    
    def boundary()
      x1, y1, w, h = [x, y, width, height].map(&:to_i)
      [x1, y1, x1+w, y1+h]
    end    
    
    def src=(s)
      
      @src = s
      
      self.attributes[:'xlink:href'] = if s =~ /^http/ then
                
        filepath = Tempfile.new('svgle').path + File.basename(s)
        File.write filepath, RXFHelper.read(s).first
        
        filepath
        
      else
        s
      end
      
    end      
    
  end    
  
  class Path < Shape
    attr2_accessor *%i(d)
    def boundary()
      [0,0,0,0]
    end    
  end  
    
  class Polygon < Shape
    attr2_accessor *%i(points)
    def boundary()
      [0,0,0,0]
    end    
  end

  class Polyline < Shape
    attr2_accessor *%i(points)
    def boundary()
      [0,0,0,0]
    end    
  end    
  
  class Rect < Shape
    
    attr2_accessor *%i(x y rx ry)
    
    def boundary()
      x1, y1, w, h = [x, y, width, height].map(&:to_i)
      [x1, y1, x1+w, y1+h]
    end    
    
  end  
  
  class Svg < SvgElement
    attr2_accessor *%i(width height background-color)
    def boundary()
      [0,0,0,0]
    end    
  end

  
  class Text < SvgElement
    
    attr2_accessor *%i(x y fill)

    def boundary()
      [0,0,0,0]
    end    
    
    def text=(raw_s)    
      
      oldval = @child_elements.first

      r = super(raw_s)
      @obj.text = raw_s if oldval != raw_s
      
      return r        
      
    end    
  end    
  
  def initialize(src='<svg/>', callback: nil, rexle: self, debug: false)
    super(src, callback: callback, rexle: rexle, debug: debug)
  end
  
  def inspect()    
    "#<Svgle:%s>" % [self.object_id]
  end  
  
  
  protected
    
  def add_default_css()
    add_css Object.const_get self.class.to_s + '::' + 'DEFAULT_' + 
        self.class.to_s.upcase + '_CSS'
    add_inline_css()
  end  

  private
  
  def defined_elements()
    {
      circle: Circle,
      ellipse: Ellipse,
      line: Line,
      g: G,
      image: Image,
      svg: Svg,
      script: Script,
      style: Style,
      doc: Rexle::Element,
      polygon: Polygon,
      polyline: Polyline,
      path: Path,
      rect: Rect,
      text: Text
    }    
  end

end
