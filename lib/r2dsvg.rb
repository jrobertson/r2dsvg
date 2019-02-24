#!/usr/bin/env ruby

# file: r2dsvg.rb

# Description: Experimental gem to render SVG within a Ruby2D application. 


require 'svgle'
require 'ruby2d'  # experimental gem depends upon simple2d binaries
require 'dom_render'



class R2dSvg
  include Ruby2D
  using ColouredText

  class Render < DomRender

    def rect(e, attributes, raw_style)

      puts 'inside rect attributes: ' + attributes.inspect if @debug
      style = style_filter(attributes).merge(raw_style)
      h = attributes

      x1, y1, width, height = %i(x y width height).map{|x| h[x].to_i }
      x2, y2, = x1 + width, y1 + height

      [:draw_rectangle, [x1, y1, x2, y2], style, render_all(e)]
    end
       
    def svg(e, attributes, raw_style)

      style = style_filter(attributes).merge(raw_style)
            
      h = attributes
      width, height = %i(width height).map{|x| h[x].to_i }
      
      [:draw_rectangle, [0, 0, width, height], style, render_all(e)]
    end    
        
    private
    
    def style_filter(attributes)
      
      %i(stroke stroke-width fill z-index).inject({}) do |r,x|
        attributes.has_key?(x) ? r.merge(x => attributes[x]) : r          
      end
      
    end

  end

  class DrawingInstructions
    using ColouredText
    
    attr_accessor :area


    def initialize(window, debug: false)

      @window, @debug = window, debug     

    end
    
    def draw_rectangle(args)

      coords, style = args

      x1, y1, x2, y2 = coords

      if @debug then
        puts 'inside draw_rectangle'.info
        puts ('style: ' + style.inspect).debug 
      end 

      @window.add Rectangle.new(
        x: x1, y: y1,
        width: x2 - x1, height: y2 - y1,
        color: style[:fill],
        z: style[:"z-index"].to_i
      )

    end
    
    def window(args)
    end

    def render(a)
      method(a[0]).call(args=a[1..2])
      draw a[3]
    end
    

    private

    def draw(a)
      
      a.each do |rawx|

        x, *remaining = rawx

        if x.is_a? Symbol then
          method(x).call(args=remaining)
        elsif x.is_a? String then
          draw remaining
        elsif x.is_a? Array
          draw remaining
        else        
          method(x).call(remaining.take 2)
        end
        
      end

    end

  end

  def initialize(svg, title: 'R2dSVG', debug: false)

    @svg, @debug = svg, debug
    doc = Svgle.new(svg, callback: self, debug: debug)
    instructions = Render.new(doc, debug: debug).to_a

    window = Window.new        
    drawing = DrawingInstructions.new window, debug: debug
    puts ('instructions: ' + instructions.inspect).debug if @debug

    @width, @height = %i(width height).map{|x| doc.root.attributes[x].to_i }
    window.set title: title, width: @width, height: @height

    drawing.render instructions
    window.show
  end
end


if __FILE__ == $0 then

  # Read an SVG file
  svg = File.read(ARGV[0])

  app = R2dSvg.new svg

end
