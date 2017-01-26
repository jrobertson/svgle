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

DEFAULT_CSS = <<CSS

svg {background-color: white}
rect {fill: yellow}
line, polyline {stroke: green; stroke-width: 3}
text {fill: red}

CSS



class Svgle < Domle
  
  
  class A < Element
    # undecided how to implement this 
    #  see http://stackoverflow.com/questions/12422668/getting-xlinkhref-attribute-of-the-svg-image-element-dynamically-using-js-i
    #attr2_accessor *%i(href)
  end    
  
  class Circle < Element
    attr2_accessor *%i(cx cy r stroke stroke-width)
    def boundary()
      [0,0,0,0]
    end    
  end

  class Ellipse < Element
    attr2_accessor *%i(cx cy rx ry)
    def boundary()
      [0,0,0,0]
    end    
  end    

  class G < Element
    attr2_accessor *%i(fill opacity)
    def boundary()
      [0,0,0,0]
    end    
  end

  class Line < Element
    attr2_accessor *%i(x1 y1 x2 y2)
    
    def boundary()
      [0,0,0,0]
    end
  end
  
  class Image < Element
    
    attr2_accessor *%i(x y width height)
    
    def boundary()
      x1, y1, w, h = [x, y, width, height].map(&:to_i)
      [x1, y1, x1+w, y1+h]
    end    
    
  end    
  
  class Path < Element
    attr2_accessor *%i(d stroke stroke-width fill)
    def boundary()
      [0,0,0,0]
    end    
  end  
    
  class Polygon < Element
    attr2_accessor *%i(points)
    def boundary()
      [0,0,0,0]
    end    
  end

  class Polyline < Element
    attr2_accessor *%i(points)
    def boundary()
      [0,0,0,0]
    end    
  end    
  
  class Rect < Element
    
    attr2_accessor *%i(x y width height rx ry)
    
    def boundary()
      x1, y1, w, h = [x, y, width, height].map(&:to_i)
      [x1, y1, x1+w, y1+h]
    end    
    
  end  
  
  class Svg < Element
    attr2_accessor *%i(width height background-color)
    def boundary()
      [0,0,0,0]
    end    
  end
  
  class Text < Element
    attr2_accessor *%i(x y fill)
    def boundary()
      [0,0,0,0]
    end    
  end    
  
  def inspect()    
    "#<Svgle:%s>" % [self.object_id]
  end  
  
  
  private
  
  def find_add_css()

    # add the default CSS

    add_css DEFAULT_CSS


    @doc.root.xpath('//style').each {|e|  add_css e.text }   

    # check for an external CSS file
    if @instructions and @instructions.any? then

      hrefs = @instructions.inject([]) do |r,x| 

        if x[0] =~ /xml-stylesheet/i and x[1] =~ /text\/css/i then

          r << x[1][/href\s*=\s*["']([^'"]+)/,1]
        else
          r
        end
      end
      
      add_css hrefs.map{|x| RXFHelper.read(x).first}.join
      
    end

  end
  
  def defined_elements()
    {
      circle: Svgle::Circle,
      ellipse: Svgle::Ellipse,
      line: Svgle::Line,
      g: Svgle::G,
      image: Svgle::Image,
      svg: Svgle::Svg,
      script: Svgle::Script,
      style: Svgle::Style,
      doc: Rexle::Element,
      polygon: Svgle::Polygon,
      polyline: Svgle::Polyline,
      path: Svgle::Path,
      rect: Svgle::Rect,
      text: Svgle::Text
    }    
  end

end
