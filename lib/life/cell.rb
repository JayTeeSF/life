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

      def self.near(_grid, _left, _top)
        return nil unless Instances
        Instances.detect do |left_coord, top_coord|
          left_coord < _left && left_coord + width >= _left && top_coord < _top && top_coord + height >= _top
        end
      end

      def self.find_near(_grid, _left, _top)
        find(_grid, *near(_grid, _left, _top))
      end

      def self.find(_grid, _left, _top)
        Instances[_left] ||= {}
        unless Instances[_left][_top]
          if _left < _grid.left_pixel_margin || _top < _grid.top_pixel_margin || _left > _grid.num_pixels_across || _top > _grid.num_pixels_down
            Instances[_left][_top] = NoCell.new(_grid, _left, _top)
          else
            warn "missing cell at #{_left}, #{_top}"
          end
        end

        Instances[_left][_top]
      end

      attr_reader :left, :top, :width, :height, :living
      alias :living? :living
      attr_accessor :new_born, :new_death
      alias :new_born? :new_born
      alias :new_death? :new_death
      def initialize(_grid, _left=nil, _top=nil, options={})
        @new_born = false
        @new_death = false
        @grid = _grid
        @width = self.class.width #options[:width] || DEFAULT_WIDTH
        @height = self.class.height #options[:height] || DEFAULT_HEIGHT
        @left = _left || Life::Grid::LEFT_MARGIN
        @top = _top ||Life::Grid::TOP_MARGIN
        @living = options.has_key?(:living) ? options[:living] : false
        Instances[@left] ||= {}
        Instances[@left][@top] = self
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
