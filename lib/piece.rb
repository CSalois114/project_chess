class Piece
  attr_reader :unicode, :color, :move_offsets

  def initialize(unicode)
    @unicode = unicode
    @color = ("2654".."2659").include?(@unicode) ? :white : :black
    @move_offsets = get_move_offsets
  end
 
  private 

  def get_move_offsets
    all_horizontals = [*-7..-1, *1..7].map{|x| [x,0]}
    all_verticals   = [*-7..-1, *1..7].map{|y| [0,y]}
    all_diagnals    = [*-7..-1, *1..7].map{|n| [n,n]} + [*-7..-1, *1..7].map{|n| [n,-n]}

    case @type
    when "2654" || "265A" #king
      @move_offsets = [[1,0], [1,1], [0,1], [-1,1], [-1,0], [-1,-1], [0,-1], [1,-1]]
    when "2655" || "265B" #queen
      @move_offsets = all_horizontals + all_verticals + all_diagnals
    when "2656" || "265C" #rook
      @move_offsets = all_horizontals + all_verticals
    when "2657" || "265D" #bishop
      @move_offsets = all_diagnals
    when "2658" || "265E" #knight
      @move_offsets = [[2,-1], [2,1], [1,2], [-1,2], [-2,1], [-2,-1], [-1,-2], [1,-2]]
    when "2659" || "265F" #pawn
      @move_offsets = [[0,1], [0,2], [-1,1], [1,1]]
    else
      @move_offsets = nil
    end
  end
end
    
