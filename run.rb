#!/usr/bin/env shoes

Root = File.dirname(__FILE__)

require "#{Root}/lib/life.rb"

game = Life.new
window_pad = 190
ever_started = false
Shoes.app :width => game.grid.width, :height => ( game.grid.height + window_pad ) do
  stack :margin => 10 do
    title game.title
    game.renderer = stack
    stack do
      flow do
        button("run") do
          game.grid.start
          ever_started = true
          @status.replace "Running..."
        end
        @status = para "Click to run"
      end
    end
  end

  game.renderer.animate(game.fps) do
    if ever_started
      game.renderer.clear do
        game.grid.update
      end
    end
  end
end
