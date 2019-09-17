class Square
  attr_reader :coords
  attr_accessor :piece
  def initialize(coords)
    @coords = coords
    @piece = nil
  end
end