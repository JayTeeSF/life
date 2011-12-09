class Life
  class Grid
    class Cell
      Instances = {}
      DEFAULT_WIDTH = 10
      DEFAULT_HEIGHT = 10
      DEFAULT_SHAPE = :rect

      NEIGHBOR_NAMES = [
        :above_left, :above,  :above_right,
        :beside_left,         :beside_right,
        :below_left, :below,  :below_right
      ]

      def self.height
        DEFAULT_HEIGHT
      end

      def self.width
        DEFAULT_WIDTH
      end

      def self.shape
        DEFAULT_SHAPE
      end

      def living_neighbor_count
        living_neighbors.size
      end

      def set_living_neighbors
        @living_neighbors = living_neighbors
      end

      def unset_living_neighbors
        @living_neighbors = nil
      end

      def living_neighbors
        @living_neighbors || neighbors.select{|n| n.living?}
      end

      def neighbors
        @neighbors ||= NEIGHBOR_NAMES.map do |direction|
          send(direction)
        end
      end

      def update
        @new_born = false
        @new_death = false
        @living = if living?
                    case living_neighbor_count
                    when  0..1
                      @new_death = true
                      false
                    when  2..3
                      true
                    when  4..8
                      @new_death = true
                      false
                    else
                      @living
                    end
                  else
                    case living_neighbor_count
                    when  3
                      @new_born = true
                      true
                    else
                      @living
                    end
                  end
      end

      def self.instance_coordinates
        Instances.keys.reduce([]) {|m1, l| m1 += Instances[l].keys.reduce([]){|m2,t| m2 << [l,t]; m2}}
      end
      def self.near(_left, _top)
        return [_left, _top] if !Instances || Instances.empty?
        instance_coordinates.detect do |lt_ary|
          left_coord = lt_ary.first; top_coord = lt_ary.last
          (left_coord < _left) && (left_coord + width >= _left) && (top_coord < _top) && (top_coord + height >= _top)
        end || [_left, _top]
      end

      # TODO: refactor - law of demeter
      def self.renderer(_grid)
        _grid.game.renderer
      end

      def self.find_near(_grid, _left, _top)
        #renderer(_grid).info("clicked: #{_left}, #{_top}")
        left_and_top = near(offset(_grid, :left, _left), offset(_grid, :top, _top))
        #renderer(_grid).info("lat: #{left_and_top.inspect}")
        find _grid, left_and_top.first, left_and_top.last
      end

      def self.offset(_grid, key, pixel_amount)
        #renderer(_grid).info("first cell: #{first_cell(_grid).inspect}")
        first_cell(_grid)[key][:grid] + (pixel_amount - first_cell(_grid)[key][:pixel])
      end

      # TODO: try caching this value from within the Shoes.app start block!
      def self.first_cell(_grid, left_margin=0, top_margin=0)
        @first_cell ||= begin
                          grid_left = Instances.keys.sort.first
                          grid_top = Instances[grid_left].keys.sort.first
                          if cell = Cell.find(_grid, grid_left, grid_top)
                            pixel_left = cell.element.left + left_margin
                            pixel_top = cell.element.top + top_margin + cell.element.parent.top

                            {
                              :left => {:pixel => pixel_left, :grid => grid_left},
                              :top  => {:pixel => pixel_top,  :grid => grid_top}
                            }
                          end
                        end
      end

      def self.find(_grid, _left, _top)
        Instances[_left] ||= {}
        unless Instances[_left][_top]
          if _left < _grid.left_pixel_margin || _top < _grid.top_pixel_margin || _left > _grid.num_pixels_across || _top > _grid.num_pixels_down
            Instances[_left][_top] = NoCell.new(_grid, _left, _top)
          else
            return nil
          end
        end

        Instances[_left][_top]
      end

      attr_reader :left, :top, :width, :height, :living, :element
      alias :living? :living
      attr_accessor :new_born, :new_death
      alias :new_born? :new_born
      alias :new_death? :new_death
      def initialize(_grid, _left=nil, _top=nil, options={})
        @renderable = true
        @new_born = false
        @new_death = false
        @grid = _grid
        @width = self.class.width #options[:width] || DEFAULT_WIDTH
        @height = self.class.height #options[:height] || DEFAULT_HEIGHT
        @left = _left || Life::Grid::LEFT_MARGIN
        @top = _top ||Life::Grid::TOP_MARGIN
        @living = options.has_key?(:living) ? options[:living] : false
        @element = nil
        Instances[@left] ||= {}
        Instances[@left][@top] = self
      end

      def renderable?
        @renderable
      end

      def render
        return unless renderable?
        @element = self.class.renderer(grid).send( Cell.shape, left, top, width, height )
      end

      def living=(bool)
        if true == bool
          self.new_death = false
          if @living != bool
            self.new_born = true
          else
            self.new_born = false
          end
        else
          self.new_born = false
          if @living != bool
            self.new_death = true
          else
            self.new_death = false
          end
        end
        @living = bool
      end

      def inspect
        "<#{self.class}: #{to_s}>"
      end

      def to_s
        "shape: #{self.class.shape}, left: #{left}, top: #{top}, width: #{width}, height: #{height}"
      end

      private
      attr_reader :grid

      def above_left
        self.class.find(grid, left - width, top - height)
      end

      def above
        self.class.find(grid, left, top - height)
      end

      def above_right
        self.class.find(grid, left + width, top - height)
      end

      def beside_left
        self.class.find(grid, left - width, top)
      end

      def beside_right
        self.class.find(grid, left + width, top)
      end

      def below_left
        self.class.find(grid, left - width, top + height)
      end

      def below
        self.class.find(grid, left, top + height)
      end

      def below_right
        self.class.find(grid, left + width, top + height)
      end
    end
  end
end
