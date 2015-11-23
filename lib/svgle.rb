#!/usr/bin/env ruby

# file: svgle.rb

require 'rexle'

# helpful SVG element references: 
#
#    * https://developer.mozilla.org/en-US/docs/Web/SVG/Element
#    * http://www.w3schools.com/svg/svg_reference.asp
#    * http://tutorials.jenkov.com/svg/svg-transformation.html#transformation-example


class Style < Hash

  def initialize(parent, h)
    @parent = parent

    super().merge! h

  end
  
  def []=(k,v)

    super(k,v)
    @parent[:style] = self.map{|x| x.join(':') }.join(';')
    @parent.callback.refresh
    
  end
end

class Attributes
  
  attr_reader :callback
  
  def initialize(parent: nil)
    @callback = parent
  end  
  
  def style(parent=nil)
    
    @callback ||= parent
    
    if @style.nil? then

      h = self[:style].split(';').inject({}) do |r, x|
        k, v = x.split(':',2)
        r.merge(k.to_sym => v)
      end

      @style = Style.new(self, h)

      h
    end
    @style
  end
  
end


class Svgle < Rexle
  
  class Element < Rexle::Element

    def initialize(name=nil, value: nil, attributes: Attributes.new(parent: self), rexle: nil)
      super(name, value: value, attributes: attributes, rexle: rexle)
      
      @boundary_box = [[0,0,0,0]]
    end
    
    def self.attr2_accessor(*a)

      a.concat %i(id transform)
      a.concat %i(onmousemove) # DOM events      
      
      a.each do |attribute|

        class_eval do

          define_method attribute.to_s.gsub('-','_').to_sym do 
            attributes[attribute]
          end

          define_method (attribute.to_s + '=').to_sym do |val|
            attributes[attribute] = val
            @rexle.refresh
            val
          end

        end
      end
    end
    
    def style()
      attributes.style(@rexle)
    end
    
    
    def hotspot?(x,y)

      (boundary.first.is_a?(Array) ? boundary : [boundary]).all? do |box|
        x1, y1, x2, y2 = box
        (x1..x2).include? x and (y1..y2).include? y
      end
    end    
  end
  
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

  class Script < Element

  end  
  
  class Style < Element

  end  
  
  
  class Svg < Element
    attr2_accessor *%i(width height)
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


  def initialize(x=nil, callback: nil)
    super x
    add_css()
    @callback = callback
  end
  
  def inspect()    
    "#<Svgle:%s>" % [self.object_id]
  end  
  
  def refresh()
    @callback.refresh if @callback
  end
  
  private
  
  def add_css()

    @doc.root.xpath('//style').each do |e|
      
      # parse the CSS
      
      a = e.text.split(/}/)[0..-2].map do |entry|

        raw_selector,raw_styles = entry.split(/{/,2)

        h = raw_styles.split(/;/).inject({}) do |r, x| 
          k, v = x.split(/:/,2).map(&:strip)
          r.merge(k.to_sym => v)
        end

        [raw_selector.split(/,\s*/).map(&:strip), h]
      end      

      
      # add the CSS style attributes to the element
      # e.g. a = [[['line'],{stroke: 'green'}]]
      
      a.each do |selectors, style|
        selectors.each do |selector|
          style.each {|k,v| self.at_css(selector).style[k] = v }
        end
      end
      
    end
    
  end
    
  def scan_element(name, attributes=nil, *children)

    return Rexle::CData.new(children.first) if name == '!['
    return Rexle::Comment.new(children.first) if name == '!-'

    type = {
      circle: Svgle::Circle,
      ellipse: Svgle::Ellipse,
      line: Svgle::Line,
      g: Svgle::G,
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

    element = type[name.to_sym].new(name, attributes: attributes, rexle: self)  

    if children then

      children.each do |x|
        if x.is_a? Array then

          element.add_element scan_element(*x)        
        elsif x.is_a? String then

          e = if x.is_a? String then

            x
          elsif x.name == '![' then

            Rexle::CData.new(x)
            
          elsif x.name == '!-' then

            Rexle::Comment.new(x)
            
          end

          element.add_element e
        end
      end
    end
    
    return element
  end

end