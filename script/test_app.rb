#!/usr/bin/env ruby
require "#{File.dirname(__FILE__) + '/../config/init.rb'}"

module CmdLine
  extend self
  def pause(msg)
    print msg
    x = gets
    puts
  end
end

puts "\n\n"
game = Life.new
puts "title: #{game.title}"
puts "fps: #{game.fps}"
puts ":width => #{game.grid.width}, :height => #{game.grid.height}"
game.renderer = FakeShoes.app
puts "\n\n"

CmdLine.pause "click to continue"

puts "\n\n"
puts "starting..."
game.grid.start
puts "\n\n"
puts game.started? ? "started" : "failed to start"
puts "\n\n"

CmdLine.pause "click to continue"

puts "\n\n"
puts "updating..."
game.grid.update
