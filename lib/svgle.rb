#!/usr/bin/env ruby

# file: svgle.rb

require 'rexle'

# helpful SVG element references: 
#
#    * https://developer.mozilla.org/en-US/docs/Web/SVG/Element
#    * http://www.w3schools.com/svg/svg_reference.asp


class Svgle < Rexle

  class Element < Rexle::Element
    
    def self.attr2_accessor(*a)

      a << :id
      
      a.each do |attribute|

        class_eval do

          define_method attribute.to_s.gsub('-','_').to_sym do 
            attributes[attribute]
          end

          define_method (attribute.to_s + '=').to_sym do |val|
            attributes[attribute] = val
          end

        end
      end
    end  
  end
  
  class A < Element
    # undecided how to implement this 
    #  see http://stackoverflow.com/questions/12422668/getting-xlinkhref-attribute-of-the-svg-image-element-dynamically-using-js-i
    #attr2_accessor *%i(href)
  end    
  
  class Circle < Element
    attr2_accessor *%i(cx cy r rx ry stroke stroke-width)
  end  

  class G < Element
    attr2_accessor *%i(fill opacity)
  end

  class Line < Element
    attr2_accessor *%i(x1 y1 x2 y2)
  end
  
  class Path < Element
    attr2_accessor *%i(d stroke stroke-width fill)
  end  
    
  class Polygon < Element
    attr2_accessor *%i(points)
  end

  class Polyline < Element
    attr2_accessor *%i(points)
  end    
  
  class Rect < Element
    attr2_accessor *%i(x y width height rx ry)
  end  

  class Svg < Element
    attr2_accessor *%i(width height)
  end
  
  class Text < Element
    attr2_accessor *%i(x y fill)
  end    


  def scan_element(name, attributes=nil, *children)

    return Rexle::CData.new(children.first) if name == '!['
    return Rexle::Comment.new(children.first) if name == '!-'

    type = {
      line: Svgle::Line,
      g: Svgle::G,
      svg: Svgle::Svg,
      doc: Rexle::Element
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