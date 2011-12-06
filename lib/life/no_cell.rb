class Life
  class Grid
    class NoCell < Cell
      def initialize(_grid, _left=nil, _top=nil, options={})
        super
        @living = false
        @new_death = false
        @new_born = false
      end
      private
      attr_accessor :new_born, :new_death
    end
  end
end
