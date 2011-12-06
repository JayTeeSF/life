#libs = []
#lib_dir_glob = "#{Init::Root}/lib/life/*.rb"
#libs += (Dir[ lib_dir_glob ] - libs)
require "#{Root}/lib/life/grid.rb"
require "#{Root}/lib/life/cell.rb"
require "#{Root}/lib/life/no_cell.rb"

class Life
  DEFAULT_FPS = 2

  attr_reader :title, :grid, :fps
  attr_accessor :renderer
  def initialize(_title="Game of Life", _renderer=nil, _width=nil, _height=nil, _fps=nil)
    @title = _title
    @renderer = _renderer
    @grid = Grid.new(self, _width, _height)
    @fps = _fps || DEFAULT_FPS
  end

  def started?
    (grid.new_death_cells + grid.new_born_cells).size > 0
  end
end
