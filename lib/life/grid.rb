class Life
  class Grid
    MARGIN = 10
    DEFAULT_WIDTH = 300
    DEFAULT_HEIGHT = 200
    DEFAULT_PERCENT_LIVING = 9

    DEFAULT_LIVE_FILL_COLOR = :blue
    DEFAULT_DIED_FILL_COLOR = :black
    DEFAULT_EMPTY_FILL_COLOR = :white
    DEFAULT_BORN_FILL_COLOR = :red

    attr_reader :width, :height
    attr_accessor :game
    def initialize(_game=nil, _width=nil, _height=nil)
      @game = _game
      @width = _width || DEFAULT_WIDTH
      @height = _height || DEFAULT_HEIGHT
      @cells = nil
      @start_cells = nil
    end

    def live_fill_color
      DEFAULT_LIVE_FILL_COLOR
    end

    def born_fill_color
      DEFAULT_BORN_FILL_COLOR
    end

    def died_fill_color
      DEFAULT_DIED_FILL_COLOR
    end

    def empty_fill_color
      DEFAULT_EMPTY_FILL_COLOR
    end

    def top_and_bottom_margins
      MARGIN * 2
    end

    def side_margins
      MARGIN * 2
    end

    def pixel(amount)
      scale(amount, 5)
    end

    def scale(amount, factor)
      amount * factor
    end

    def num_across
      (width - side_margins) / Cell.width
    end

    def num_down
      (height - top_and_bottom_margins) / Cell.height
    end

    def num_pixels_down
      pixel(num_down)
    end

    def num_pixels_across
      pixel(num_across)
    end

    def top_pixel_margin
      pixel(top_and_bottom_margins / 2)
    end

    def left_pixel_margin
      pixel(side_margins / 2)
    end

    def right_pixel_margin
      left_pixel_margin + num_pixels_across # + Cell.width
    end

    def bottom_pixel_margin
      top_pixel_margin + num_pixels_down # + Cell.height
    end

    def cells
      @cells ||= []
      if @cells.empty?
        across_array = left_pixel_margin.step(num_pixels_across, Cell.width).to_a
        down_array = top_pixel_margin.step(num_pixels_down, Cell.height).to_a
        across_array.each do |left|
          down_array.each do |top|
            @cells << Cell.new(self, left, top)
          end
        end
      end
      @cells
    end

    def random_choices(percent_true=50)
      @random_choices ||= {}
      @random_choices[percent_true] ||= []

      if @random_choices[percent_true].empty?
        percent_true.times { @random_choices[percent_true] << true }
        (100 - @random_choices[percent_true].size).times { @random_choices[percent_true] << false }
      end

      @random_choices[percent_true]
    end

    def seed(percent_living=DEFAULT_PERCENT_LIVING)
      choices = random_choices(percent_living)
      cells.each do |cell|
        cell.living = choices[rand(choices.size)]
      end
    end

    def new_death_cells
      cells.select{|cell| cell.new_death?}
    end

    def new_born_cells
      cells.select{|cell| cell.new_born?}
    end

    def living_cells
      cells.select{|cell| cell.living?}
    end

    def long_living_cells
      living_cells - new_born_cells
    end

    def empty_cells
      cells - living_cells
    end

    def long_dead_or_never_alive_cells
      empty_cells - new_death_cells
    end

    def display(cell_list, color)
      raise "Missing renderer" unless game.renderer
      game.renderer.fill game.renderer.send(color)
      cell_list.each do |cell|
        game.renderer.send( Cell.shape, cell.top, cell.left, cell.width, cell.height )
      end
    end

    def display_new_born_cells
      display(new_born_cells, born_fill_color)
    end

    def display_new_death_cells
      display(new_death_cells, died_fill_color)
    end

    def display_long_living_cells
      display(long_living_cells, live_fill_color)
    end

    def display_long_dead_or_never_alive_cells
      display(long_dead_or_never_alive_cells, empty_fill_color)
    end

    def update
      cells.map(&:set_living_neighbors)
      cells.map(&:update)
      cells.map(&:unset_living_neighbors)
      render
    end

    def render
      display_new_born_cells
      display_new_death_cells
      display_long_living_cells
      display_long_dead_or_never_alive_cells
    end

    def start
      seed
      render
    end

  end
end
