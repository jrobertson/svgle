#!/usr/bin/env ruby

# file: svgle.rb

require 'rexle'


class Svgle < Rexle

  class Element < Rexle::Element
  end

  class G < Element
  end

  class Line < Element
    def x1()
      attributes[:x1]
    end
    def x1=(v)
      attributes[:x1] = v
    end
  end

  class Svg < Element
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
