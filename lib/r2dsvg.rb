#!/usr/bin/env ruby

# file: r2dsvg.rb

# Description: Experimental gem to render SVG within a Ruby2D application. 


require 'svgle'
require 'onedrb'
require 'ruby2d'  # experimental gem depends upon simple2d binaries
require 'dom_render'


DEFAULT_CSS = <<CSS

svg {background-color: white}
rect {fill: yellow}
line, polyline {stroke: green; stroke-width: 3}
text {fill: red, size: 20}

CSS

module SvgleX
  
  refine Svgle::Element do
    
    def obj=(object)
      @obj = object
    end
    
    def obj()
      @obj
    end
    
  end
  
end

class R2dSvg
  include Ruby2D
  using ColouredText
  using SvgleX

  class Render < DomRender
    
    def audio(e, attributes, raw_style)

      puts 'inside audio attributes: ' + attributes.inspect if @debug
      style = style_filter(attributes).merge(raw_style)
      h = attributes

      sources = e.xpath('source').map do |x|
        h = x.attributes.to_h
        h.delete :style
        h
      end

      [:embed_audio, sources, e]
    end    
    
    def circle(e, attributes, raw_style)

      style = style_filter(attributes).merge(raw_style)

      h = attributes

      x, y, radius= %i(cx cy r).map{|x| h[x].to_i }
      fill = h[:fill]
      

      [:draw_circle, [x, y], radius, fill, style, render_all(e)]
    end       
    
    # not yet implemented
    #
    def ellipse(e, attributes, raw_style)

      style = style_filter(attributes).merge(raw_style)
      h = attributes

      x, y= %i(cx cy).map{|x| h[x].to_i }
      width = h[:rx].to_i * 2
      height = h[:ry].to_i * 2

      [:draw_arc, [x, y, width, height], style, render_all(e)]
    end    
    
    def line(e, attributes, raw_style)

      style = style_filter(attributes).merge(raw_style)

      x1, y1, x2, y2 = %i(x1 y1 x2 y2).map{|x| attributes[x].to_i }

      [:draw_line, [x1, y1, x2, y2], style, render_all(e)]
    end   
        
    
    def image(e, attributes, raw_style)

      style = style_filter(attributes).merge(raw_style)
      h = attributes

      x, y, width, height = %i(x y width height).map{|x| h[x] ? h[x].to_i : nil }
      src = h[:'xlink:href']

      [:draw_image, [x, y, width, height], src, style, e, render_all(e)]
    end       
    
    def polygon(e, attributes, raw_style)

      style = style_filter(attributes).merge(raw_style)
      points = attributes[:points].split(/\s+/). \
                                       map {|x| x.split(/\s*,\s*/).map(&:to_i)}

      [:draw_polygon, points, style, e, render_all(e)]
    end

    def polyline(e, attributes, raw_style)

      style = style_filter(attributes).merge(raw_style)
      points = attributes[:points].split(/\s+/). \
                                       map {|x| x.split(/\s*,\s*/).map(&:to_i)}

      [:draw_lines, points, style, render_all(e)]
    end      

    def rect(e, attributes, raw_style)

      puts 'inside rect attributes: ' + attributes.inspect if @debug
      style = style_filter(attributes).merge(raw_style)
      h = attributes

      x1, y1, width, height = %i(x y width height).map{|x| h[x].to_i }
      x2, y2, = x1 + width, y1 + height

      [:draw_rectangle, [x1, y1, x2, y2], style, e, render_all(e)]
    end
    
    def script(e, attributes, style)
      [:script]
    end     
       
    def svg(e, attributes, raw_style)

      style = style_filter(attributes).merge(raw_style)
            
      h = attributes
      width, height = %i(width height).map{|x| h[x].to_i }
      
      [:draw_rectangle, [0, 0, width, height], style, render_all(e)]
    end    
    
    def text(e, attributes, raw_style)

      style = style_filter(attributes).merge(raw_style)
      style.merge!({font_size: '20'})

      x, y = %i(x y).map{|x| attributes[x].to_i }

      [:draw_text, [x, y], e.text, style, e, render_all(e)]
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
    
    def draw_arc(args)

      dimensions, style = args

      x, y, width, height = dimensions

      #gc = gc_ini(fill: style[:fill] || :none)
      #@area.window.draw_arc(gc, 1, x, y, width, height, 0, 64 * 360)
    end      
    
    def draw_circle(args)

      coords, radius, fill, style, e = args

      x1, y1 = coords

      if @debug then
        puts 'inside draw_circle'.info
        puts ('style: ' + style.inspect).debug 
      end 

      obj = Circle.new(
        x: x1, y: y1,
        radius: radius,
        sectors: 32,
        color: style[:fill],
        z: style[:"z-index"].to_i
      )
      e.obj = obj if e.respond_to? :obj=
      @window.add obj

    end    
    
    def draw_image(args)

      dimensions, src, style, e = args

      x, y, width, height = dimensions      
      
      filepath = Tempfile.new('r2dsvg').path + File.basename(src)
      puts 'filepath: ' + filepath.inspect if @debug
      File.write filepath, RXFHelper.read(src).first
        
      
      if File.exists? filepath then

        obj = Image.new(
          filepath,
          x: x, y: y,
          width: width, height: height,
          color: style[:fill],
          z: style[:"z-index"].to_i
        )        

        e.obj = obj if e.respond_to? :obj=
        @window.add obj
      end
    end     
    
    def draw_line(args)

      coords, style, e = args

      x1, y1, x2, y2 = coords

      if @debug then
        puts 'inside draw_rectangle'.info
        puts ('style: ' + style.inspect).debug 
      end 

      obj = Line.new(
        x1: x1, y1: y1,
        x2: x2, y2: y2,
        width: style[:"stroke-width"].to_f,
        color: style[:"stroke"],
        z: style[:"z-index"].to_i
      ) 
      
      e.obj = obj if e.respond_to? :obj=
      @window.add obj
      
    end    
    
    def draw_polygon(args)

      vertices, style, e = args

      puts ('vertices: ' + vertices.inspect).debug if @debug      

      if @debug then
        puts 'inside draw_polygon'.info
        puts ('style: ' + style.inspect).debug 
      end 
      
      puts ('vertices: ' + vertices.inspect).debug if @debug      
      
      h = vertices.map.with_index do |coords,i|

        %w(x y).zip(coords).map {|key, c| [(key + (i+1).to_s).to_sym, c] }
        
      end.flatten(1).to_h
      puts ('triangle h: ' + h.inspect).debug if @debug      

      puts ('triangle h merged: ' + h.inspect).debug if @debug
      obj = Triangle.new(h.merge({color: style[:fill], z: style[:"z-index"].to_i}))
      e.obj = obj if e.respond_to? :obj=
      @window.add obj
    end       


    # not yet implemented
    #
    def draw_lines(args)

      coords, width, style, e = args

      x1, y1, x2, y2 = coords

     
    end       
    
    def draw_rectangle(args)

      coords, style, e = args

      x1, y1, x2, y2 = coords

      if @debug then
        puts 'inside draw_rectangle'.info
        puts ('style: ' + style.inspect).debug 
      end 

      obj = Rectangle.new(
        x: x1, y: y1,
        width: x2 - x1, height: y2 - y1,
        color: style[:fill],
        z: style[:"z-index"].to_i
      )
      e.obj = obj if e.respond_to? :obj=
      @window.add obj

    end
    
    def draw_text(args)

      coords, text, style, e = args

      x, y = coords

      if @debug then
        puts 'inside draw_text'.info
        puts ('style: ' + style.inspect).debug 
      end 
     
      obj = Text.new(
        text,
        x: x, y: y,
        #font: 'vera.ttf',
        size: style[:font_size].to_i,
        color: style[:color],
        z: style[:"z-index"].to_i
      )
      e.obj = obj
      @window.add obj

    end
    
    # Ruby 2D supports a number of popular audio formats, including WAV, 
    # MP3, Ogg Vorbis, and FLAC.

    def embed_audio(args)
      
      sources, e = args

      if @debug then
        puts 'sources: ' + sources.inspect if @debug
        puts 'inside embed_audio'.info
      end 
     
      
      audio_files = sources.map do |source|
        
        filepath = Tempfile.new('r2dsvg').path + File.basename(source[:src])
        File.write filepath, RXFHelper.read(source[:src]).first
        filepath
      end
      
      audio = audio_files.find {|file| File.exists? file }
      
      return unless audio
      
      file = File.exists?(audio) ? audio : nil
      puts 'file: ' + file.inspect if @debug

      obj = Sound.new(file)
      e.obj = obj
      
      def e.play() self.obj.play()  end

    end     
    
    def window(args)
    end

    def render(a)
      method(a[0]).call(args=a[1..2])
      draw a[3]
    end
    
    def script(args)

    end         

    private

    def draw(a)
  
      threads = []
      
      a.each do |rawx|
  
        threads << Thread.new do
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
      
      threads.join

    end

  end
  
  attr_reader :doc

  def initialize(s, title: 'R2dSVG', debug: false)

    @debug = debug
    
    @window = window = Window.new
    
    @doc = read(s, title)    

    drb = OneDrb::Server.new host: '127.0.0.1', port: '57844', obj: self
    Thread.new { drb.start }
    
    window.on(:mouse_move) do |event|
      mouse :mousemove, event
      mouse :mouseenter, event
    end
    
    window.on(:mouse_down) do |event|
      
      if event.button == :left then
        
        # click and mousedown do the same thing
        mouse :click, event 
        mouse :mousedown, event
      end
      
    end          

    window.show
    
    
  end
  
  def read(s, title=@title)

    svg, _ = RXFHelper.read(s)    
    doc = Svgle.new(svg, callback: self, debug: @debug)
    instructions = Render.new(doc, debug: @debug).to_a

 
    drawing = DrawingInstructions.new @window, debug: @debug
    puts ('instructions: ' + instructions.inspect).debug if @debug

    @width, @height = %i(width height).map{|x| doc.root.attributes[x].to_i }
    @window.set title: title, width: @width, height: @height        
    
    Thread.new do
      doc.root.xpath('//script').each {|x| eval x.text.unescape }      
      drawing.render instructions    
    end
    
    doc
    
  end  
  
  
  private
  
  def mouse(action, event)
    
    doc = @doc
    
    @doc.root.xpath("//*[@on#{action}]").each do |x|

      #puts 'x.class: ' + x.inspect if @debug
      if x.obj and x.obj.contains? event.x, event.y then
        
          
        if not x.active? then
          x.active = true
        elsif action == :mouseenter
          next
        end
                  
        if block_given? then
          valid = yield(x)
          statement = x.method(('on' + action.to_s).to_sym).call()
          puts 'statement: ' + statement.inspect if @debug
          eval statement if valid
        else
          statement = x.method(('on' + action.to_s).to_sym).call()
          puts 'statement: ' + statement.inspect if @debug
          eval statement
        end
        
      else
        
        if x.active? then
          x.active = false
          onleave
        end
      end
    
    end
        
  end
  
  def onleave()

    @doc.root.xpath("//*[@onmouseleave]").each do |x|
      puts 'onleave'.info if @debug
      eval x.method(:onmouseleave).call()
    end

  end    
    
end


if __FILE__ == $0 then

  # Read an SVG file
  svg = File.read(ARGV[0])

  app = R2dSvg.new svg

end
