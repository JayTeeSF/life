#libs = []
#lib_dir_glob = "#{Init::Root}/lib/life/*.rb"
#libs += (Dir[ lib_dir_glob ] - libs)
require "#{Root}/lib/life/grid.rb"
require "#{Root}/lib/life/cell.rb"
require "#{Root}/lib/life/no_cell.rb"

class Life
  DEFAULT_FPS = 2

  attr_reader :title, :grid, :fps
  attr_accessor :renderer, :started, :animation_stack, :click_stack
  def initialize(_title="Game of Life", _renderer=nil, _width=nil, _height=nil, _fps=nil)
    @title = _title
    @renderer = _renderer
    @grid = Grid.new(self, _width, _height)
    @fps = _fps || DEFAULT_FPS
    @seeded = true #odd, I know...
    @started = false
  end

  def started?
    @started
  end

  def seeded?
    @seeded
  end

  def seed
    return if @click_stack && !@seeded
    @seeded = false
    renderer.app.info("ready to seed")
    return if @click_stack
    this = self
    renderer.app.info("initializing seeder")
    click_stack = true
    renderer.app do
      click do |button, left, top|
        unless this.seeded?
          #alert("left: #{left}, top: #{top}")
          cell = Cell.find_near(this.grid, left, top)
          # toggle:
          cell.living? ? cell.living = false : cell.living = true
        end
      end
    end
  end

  def seeded
    renderer.app.info("done seeding")
    @seeded = true
  end

  def self.start
    game = Life.new
    Shoes.app :width => game.grid.width, :height => game.grid.height, :title => game.title do
      stack :margin => 10 do
        stack do
          background '#fd9', :curve => 12
          tagline game.title, :align => "center"
          flow do
            button("auto-seed") do
              game.grid.start
            end
            button("manual-seed") do
              # toggle
              if game.seeded?
                alert("unimplemented")
                game.seed
              else
                game.seeded
                game.grid.render
              end
            end
            button("run") do
              game.start_animation
            end
            button("stop") do
              game.stop_animation
            end
            button("clear") do
              game.grid.clear
            end
          end
        end

        game.renderer = stack
        game.grid.clear
      end
    end
  end

  def stop_animation
    @started = false
    #if @animation_stack
    #  renderer.app.info("got stack")
    #  @animation_stack.clear
    #end
  end

  def start_animation
    return if @started
    @started = true
    return if @animation_stack
    this = self
    renderer.app do
      this.animation_stack = stack do
        animate(this.fps) do
          if this.started
            this.renderer.clear do
              this.grid.update
            end
          end
        end
      end
    end
  end

end
