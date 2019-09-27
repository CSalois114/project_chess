require_relative "piece"
require_relative "square"
require_relative "saving"

class Board
  include Saving

  attr_reader :squares 
  attr_accessor :turn_color

  def initialize
    @turn_color = :white
    @squares = {}
    (1..8).each{|x| (1..8).each{|y| @squares[ [x, y] ] = Square.new([x,y]) } }
    set_pieces_for_new_game
  end

  def move(origin_coords, destination_coords)
    @squares[destination_coords].piece = @squares[origin_coords].piece
    @squares[origin_coords].piece = nil
    @turn_color = @turn_color == :white ? :black : :white
  end

  def legal_move?(origin_coords, destination_coords, ignore_turn_color=false)
    return false unless @squares[origin_coords] && @squares[destination_coords] && @squares[origin_coords].piece  
    return false unless (@squares[origin_coords].piece.color == @turn_color || ignore_turn_color)

    move_offsets = get_coord_offsets(origin_coords, destination_coords)
    piece = @squares[origin_coords].piece
    return false unless piece.move_offsets.include?(move_offsets)
    #If the destination square is occupied
    if @squares[destination_coords].piece
      return false if piece.color == @squares[destination_coords].piece.color
      #If the piece is a pawn, it can't attack straight ahead
      return false if ["\u2659", "\u265F"].include?(piece.unicode) && 
        [[0, 1], [0, 2], [0, -1], [0, -2]].include?(move_offsets)
    end
    #Check for clear line of attack if piece is a queen, rook, or bishop
    if ["\u2655", "\u265B", "\u2656", "\u265C", "\u2657", "\u265D"].include?(piece.unicode)
      return false if get_squares_between(origin_coords, destination_coords).any? {|square| square.piece}
    end
    #Pawns can only move two spaces if origin_square is the square they start the game on
    return false if piece.unicode == "\u2659" && move_offsets == [0, 2] && origin_coords[1] != 2
    return false if piece.unicode == "\u265F" && move_offsets == [0, -2] && origin_coords[1] != 7
    #move can't expose king to check
    return false if moving_into_check?(origin_coords, destination_coords)
    return true
    true
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
      return nil if @squares[destination_coords] && legal_move?(king_square.coords.dup, destination_coords)
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
  
  def display 
    system("clear") || system("cls")
    puts "    a   b   c   d   e   f   g   h  "
    puts "  +---+---+---+---+---+---+---+---+"
    (1..8).reverse_each do |y|  #puts each row of the board
      puts "#{y} | #{(1..8).map{|x| @squares[[x,y]].piece ? @squares[[x,y]].piece.unicode : " "}.join(" | ")} |"
      puts "  +---+---+---+---+---+---+---+---+"
    end
    puts "    a   b   c   d   e   f   g   h  "
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
      legal_move?(square.coords.dup, target_square.coords.dup, true)
    end
  end

  def moving_into_check?(origin_coords, destination_coords)
     #Saves destination squares piece if there is one so that it can temporarily be replaced
    destination_piece = @squares[destination_coords].piece.dup
    @squares[destination_coords].piece = @squares[origin_coords].piece
    @squares[origin_coords].piece = nil
    moving_into_check = get_checked_color == @turn_color
    @squares[origin_coords].piece = @squares[destination_coords].piece
    @squares[destination_coords].piece = destination_piece
    return moving_into_check
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
