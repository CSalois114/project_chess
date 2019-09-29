require_relative "piece"
require_relative "square"
require_relative "saving"
require_relative "display"
require_relative "move"

class Board
  include Saving
  include Display
  include Move

  attr_reader :squares 
  attr_accessor :turn_color

  def initialize
    @turn_color = :white
    @squares = {}
    (1..8).each{|x| (1..8).each{|y| @squares[ [x, y] ] = Square.new([x,y]) } }
    set_pieces_for_new_game
  end

  def get_checked_color
    king_squares = get_king_squares
    king_squares.each do |king_square|
      return king_square.piece.color if get_squares_that_can_attack(king_square).length > 0
    end
    return nil
  end

  def get_checkmated_color
    return nil unless get_checked_color
    king_square = get_king_squares.select {|square| square.piece.color == get_checked_color}.pop
    #check if the king can move out of check
    king_square.piece.move_offsets.each do |offsets|
      destination_coords = [king_square.coords[0] + offsets[0], king_square.coords[1] + offsets[1]]
      return nil if @squares[destination_coords] && 
                    legal_move?(king_square.coords.dup, destination_coords, false, false)
    end
    #check if only one piece is attacking the king and if it can be killed or blocked
    if get_squares_that_can_attack(king_square).length == 1
      attacking_square = get_squares_that_can_attack(king_square).pop
      return nil if get_squares_that_can_attack(attacking_square).length > 0
      return nil if attack_blockable?(attacking_square, king_square)
    end
    return king_square.piece.color
  end

  def get_result
    return get_checkmated_color == :white ? :black : :white if get_checkmated_color
    return :draw if @squares.values.select {|square| square.piece}.all? do |square|
      ["\u2654", "\u265A"].include?(square.piece.unicode) if square.piece
    end
    return nil
  end
  
  private

  def attack_blockable?(attacking_square, king_square)
    if ["\u2655", "\u265B", "\u2656", "\u265C", "\u2657", "\u265D"].include?(attacking_square.piece.unicode)
      get_squares_between(attacking_square.coords.dup, king_square.coords.dup).each do |square| 
        return true if get_squares_that_can_attack(square).length > 0
      end
    end
    return false
  end

  def get_squares_that_can_attack(target_square)
    target_color = target_square.piece ? target_square.piece.color : @turn_color == :white ? :black : :white
    squares_that_can_attack = @squares.values.select do |square| 
      square.piece && square.piece.color != target_color && 
      square.piece.move_offsets.include?(get_coord_offsets(square.coords.dup, target_square.coords.dup)) &&
      legal_move?(square.coords.dup, target_square.coords.dup, true, false)
    end
  end

  def get_squares_between(origin_coords, destination_coords)
    offsets = get_coord_offsets(origin_coords, destination_coords)
    test_coords = origin_coords
    squares_between = []
    ((offsets[0] != 0 ? offsets[0].abs : offsets[1].abs) - 1).times do
      [0, 1].each {|n| test_coords[n] +=  offsets[n]/(offsets[n].abs) unless offsets[n] == 0}
      squares_between << @squares[test_coords]
    end
    return squares_between  
  end  

  def get_coord_offsets(origin_coords, destination_coords)
    [destination_coords[0] - origin_coords[0], destination_coords[1] - origin_coords[1]]
  end
  
  def get_king_squares
    @squares.values.select {|square| square.piece && ["\u2654", "\u265A"].include?(square.piece.unicode)}
  end

  def set_pieces_for_new_game
    #set kings
    @squares[[5, 1]].piece = Piece.new("\u2654")
    @squares[[5, 8]].piece = Piece.new("\u265A")
    #set queens
    @squares[[4, 1]].piece = Piece.new("\u2655")
    @squares[[4, 8]].piece = Piece.new("\u265B")
    #set rooks
    [1, 8].each {|n| @squares[[n, 1]].piece = Piece.new("\u2656")}
    [1, 8].each {|n| @squares[[n, 8]].piece = Piece.new("\u265C")}
    #set bishops
    [3, 6].each {|n| @squares[[n, 1]].piece = Piece.new("\u2657")}
    [3, 6].each {|n| @squares[[n, 8]].piece = Piece.new("\u265D")}
    #set knights
    [2, 7].each {|n| @squares[[n, 1]].piece = Piece.new("\u2658")}
    [2, 7].each {|n| @squares[[n, 8]].piece = Piece.new("\u265E")}
    #set pawns
    (1..8).each {|n| @squares[[n, 2]].piece = Piece.new("\u2659")}
    (1..8).each {|n| @squares[[n, 7]].piece = Piece.new("\u265F")}
  end
end