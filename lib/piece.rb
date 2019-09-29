class Piece
  attr_reader :unicode, :color, :move_offsets

  def initialize(unicode)
    @unicode = unicode
    @color = ["\u2654","\u2655","\u2656","\u2657","\u2658","\u2659"].include?(@unicode) ? :white : :black
    @move_offsets = get_move_offsets
  end
 
  private 

  def get_move_offsets
    all_horizontals = [*-7..-1, *1..7].map{|x| [x,0]}
    all_verticals   = [*-7..-1, *1..7].map{|y| [0,y]}
    all_diagnals    = [*-7..-1, *1..7].map{|n| [n,n]} + [*-7..-1, *1..7].map{|n| [n,-n]}

    case @unicode
    when "\u2654", "\u265A" #king
      @move_offsets = [[1,0], [1,1], [0,1], [-1,1], [-1,0], [-1,-1], [0,-1], [1,-1]]
    when "\u2655", "\u265B" #queen
      @move_offsets = all_horizontals + all_verticals + all_diagnals
    when "\u2656", "\u265C" #rook
      @move_offsets = all_horizontals + all_verticals
    when "\u2657", "\u265D" #bishop
      @move_offsets = all_diagnals
    when "\u2658", "\u265E" #knight
      @move_offsets = [[2,-1], [2,1], [1,2], [-1,2], [-2,1], [-2,-1], [-1,-2], [1,-2]]
    when "\u2659"             #white pawn
      @move_offsets = [[0,1], [0,2], [-1,1], [1,1]]
    when "\u265F"             #black pawn
      @move_offsets = [[0,-1], [0,-2], [-1,-1], [1,-1]]
    else
      @move_offsets = nil
    end
  end
end