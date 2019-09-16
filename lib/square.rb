class Square
  attr_reader :coords, :piece
  def initialize(coords)
    @coords = coords
    @piece = nil
  end
end