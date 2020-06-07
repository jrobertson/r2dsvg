#!/usr/bin/env ruby

# file: r2dsvg.rb

# Description: Experimental gem to render SVG within a Ruby2D application. 


require 'r2dsvg/r2dsvg_module'


class Reader
  include R2dEngine
  using ColouredText
  
  def initialize(s, model=Svgle, debug: false)
    
    svg, _ = RXFHelper.read(s)    
    doc = model.new(svg, debug: debug)
    @a = Render.new(doc, debug: debug).to_a    
    
    
  end
  
  def to_a()
    @a
  end
  
end

class R2dSvg
  include Ruby2D
  include R2dEngine
  using ColouredText
  using SvgleX

  attr_reader :doc

  def initialize(s, title: 'R2dSVG', debug: false, server: false)

    @debug = debug
    
    @window = window = Window.new
    @loaded = false
    @model = Svgle
    
    read(s, title)    

    if server then
      drb = OneDrb::Server.new(host: '127.0.0.1', port: '57844', obj: self)
      Thread.new { drb.start }
    end
    
    if @loaded then
      
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
    
      window.on :key_down do |event|
        # A key was pressed
        keyboard :keydown, event
      end
      
    end
=begin     
    window.on :key_held do |event|
      # A key is being held down
      puts event.key
      keyboard :onkeyheld, event
    end
    
    window.on :key_up do |event|
      # A key was released
      puts event.key
      keyboard :onkeyup, event
    end    
=end
    window.show
    
    
  end
  
  def clear()
    @window.clear
  end
  
  def read(unknown, title=@title)

    @loaded = false
    @window.clear
    doc = nil
    
    if unknown.is_a? String
      
      svg, _ = RXFHelper.read(unknown)    
      doc = @model.new(svg, callback: self, debug: @debug)
      instructions = Render.new(doc, debug: @debug).to_a      

    elsif unknown.is_a? Array
      
      puts 'array found' if @debug
      
      instructions = unknown
      
    end
 
    drawing = DrawingInstructions.new @window, debug: @debug

    if doc then    
      
      @width, @height = %i(width height).map{|x| doc.root.attributes[x].to_i }
      @window.set title: title, width: @width, height: @height        
    

      threads = []
      
      threads << Thread.new do
        doc.root.xpath('//script').each {|x| eval x.texts.join }      
        drawing.render instructions   
      end
      
      threads.join

      @loaded = true
      @doc = doc
      
    else
      
      drawing.render instructions   
      h = instructions[2]
      @width, @height = h[:width].to_i, h[:height].to_i
      @window.set title: 'Untitled', width: @width, height: @height    
    end
    
  end  
  
  def refresh()
    puts 'do nothing' if @debug
  end
  
  
  private
  
  def keyboard(action, event)
    
    doc = @doc
    
    @doc.root.xpath("//*[@on#{action}]").each do |x|

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
    
    end
    
    @doc.event[action].each {|name| method(name).call event }
        
  end  
  
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
