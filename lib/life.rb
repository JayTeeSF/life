#libs = []
#lib_dir_glob = "#{Init::Root}/lib/life/*.rb"
#libs += (Dir[ lib_dir_glob ] - libs)
require "#{Root}/lib/life/grid.rb"
require "#{Root}/lib/life/cell.rb"
require "#{Root}/lib/life/no_cell.rb"

class Life
  DEFAULT_FPS = 2

  attr_reader :title, :grid
  attr_accessor :renderer, :started, :animation, :click_stack, :fps
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
          if cell = Grid::Cell.find_near(this.grid, left, top)
            # toggle:
            if cell.living?
              cell.living = false
              color = this.grid.empty_fill_color
            else
              cell.living = true
              color = this.grid.born_fill_color
            end
            this.grid.display([cell], color)
          end
          #alert("left: #{left}, top: #{top}")
        end
      end
    end
  end

  def seeded
    renderer.app.info("done seeding")
    @seeded = true
  end

  def self.controls
    @controls ||= {}
  end
  def self.padding
    @padding ||= {:stack_margin => 10, :bottom_margin => 40}
  end

  def self.start(game = Life.new, shoes=Shoes)
    this = self # Life class
    shoes.app :width => game.grid.width, :height => game.grid.height + this.padding[:bottom_margin], :title => game.title do
      background red..black
      stack :margin => this.padding[:stack_margin] do
        stack do
          background '#fd9', :curve => 12
          tagline game.title, :align => "center"
          flow do
            stack :width => '15%' do
              button("seed") do
                if this.controls[:auto_seed].checked?
                  game.grid.start
                else
                  # toggle
                  if game.seeded?
                    @status.replace("manual seeding...")
                    game.seed
                  else
                    @status.replace("")
                    game.seeded
                  end
                end
              end
            end
            stack :width => '25%' do
              flow do
                this.controls[:auto_seed] = radio(:seed); para "auto"
              end
              flow do
                this.controls[:manual_seed] = radio(:seed); para "manual"
              end
            end

            this.controls[:auto_seed].click do |radio|
              info("auto_seed mode")
            end

            this.controls[:manual_seed].click do |radio|
              info("manual_seed mode")
            end

            stack :width => '25%' do
              flow do
                this.controls[:two_tone] = radio(:colors); para "two tone"
              end
              flow do
                this.controls[:multi_tone] = radio(:colors); para "multi tone"
              end
            end

            this.controls[:two_tone].click do |radio|
              game.grid.two_color
              info("two_tone mode")
            end

            this.controls[:multi_tone].click do |radio|
              game.grid.multi_color
              info("multi_tone mode")
            end

            stack :width => '20%' do
              flow do
                this.controls[:start_button] = button("start") do
                  game.start_animation
                  info("animation started")
                end
                  #radio(:start_stop); para "start"
              end
              flow do
                this.controls[:stop_button] = button("stop") do |radio|
                  game.stop_animation
                  info("animation stopped")
                end
                  #radio(:start_stop); para "stop"
              end
            end
            stack :width => '15%' do
              this.controls[:quit_button] = button("quit") do
                exit
              end
              this.controls[:clear_button] = button("clear") do
                #this.controls[:stop_radio_button].checked = true
                game.grid.clear
              end
            end
          end
        end

        game.renderer = stack
        @status = para "", :size => 8
        game.grid.clear
        info("stack left:#{game.renderer.left.inspect}, top: #{game.renderer.top.inspect}") 
      end
      start do
        info("start block")
        this.controls[:two_tone].checked = true
        #this.controls[:stop_radio_button].checked = true
        this.controls[:manual_seed].checked = true
        Grid::Cell.first_cell(game.grid, this.padding[:stack_margin], this.padding[:stack_margin])
      end
    end
  end

  def stop_animation
    @started = false
    #if @animation
    #  renderer.app.info("got stack")
    #  @animation
    #end
  end

  def start_animation
    return if @started
    @started = true
    renderer.info("animation: #{animation.inspect}")
    return if @animation
    this = self
    renderer.app do
      stack do
        this.animation = animate(this.fps) do
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
