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
  
  def legal_non_king_move?(origin_coords, destination_coords, test_run=false)
    return false unless @squares[origin_coords] && @squares[destination_coords] && @squares[origin_coords].piece
    #test_run should be set to true when you want to test a move out of turn of the game
    #this is used by #check? to see if a piece could attack the king
    unless test_run
      return false unless @squares[origin_coords].piece.color == @turn_color
    end
    move_offsets = get_coord_offsets(origin_coords, destination_coords)
    piece = @squares[origin_coords].piece
    return false unless piece.move_offsets.include?(move_offsets)
    #If the destination square is occupied
    if @squares[destination_coords].piece
      return false if piece.color == @squares[destination_coords].piece.color
      #If the piece is a pawn, it can't attack straight ahead
      return false if ["\u2659", "\u265F"].include?(piece.unicode) && 
        [[0, 1],[0, 2],[0, -1],[0, -2]].include?(move_offsets)
    end
    #Check for clear line of attack if piece is a queen, rook, or bishop
    if ["\u2655", "\u265B", "\u2656", "\u265C", "\u2657", "\u265D"].include?(piece.unicode)
      return false unless line_to_destination_clear?(origin_coords, destination_coords)
    end
    #Pawns can only move two spaces if origin_square is the square they start on
    return false if piece.unicode == "\u2659" && move_offsets == [0, 2] && origin_coords[1] != 2
    return false if piece.unicode == "\u265F" && move_offsets == [0, -2] && origin_coords[1] != 7

    return true
  end

  def legal_king_move?(origin_coords, destination_coords)
    #See if it's a legal move disregarding if the king will be in check.
    return false unless legal_non_king_move?(origin_coords, destination_coords)
    #Saves destination squares piece if there is one so that it can temporarily be replaced
    #with the moving king to see if it will be in check at the destination.
    destination_current_piece = @squares[destination_coords].piece
    @squares[destination_coords].piece = @squares[origin_coords].piece
    legal = check?(destination_coords) ? false : true
    #Replace the piece that should currently be at the destination.
    @squares[destination_coords].piece = destination_current_piece
    legal
  end

  def check?(king_coords)
    king_color = @squares[king_coords].piece.color
    #Gets all the squares with the opposite color pieces
    enemy_squares_array = @squares.values.select {|square| square.piece.color != king_color if square.piece}
    enemy_squares_array.each do |square|
      #If any enemy has the potential to attack the king, check if that move is legal.
      if square.piece.move_offsets.include?(get_coord_offsets(square.coords.dup, king_coords))
         return true if legal_non_king_move?(square.coords.dup, king_coords, true)
      end
    end
    return false
  end

  def checkmate?(king_coords)
    return false unless check?(king_coords) 
    @squares[king_coords].piece.move_offsets.each do |offsets|
      destination_coords = [king_coords[0] + offsets[0], king_coords[1] + offsets[1]]
      return false if @squares[destination_coords] && legal_king_move?(king_coords, destination_coords)
    end
    true
  end
  
  def display 
    system("clear") || system("cls")
    puts "    1   2   3   4   5   6   7   8  "
    puts "  +---+---+---+---+---+---+---+---+"
    (1..8).reverse_each do |y|  #puts each row of the board
      puts "#{y} | #{(1..8).map{|x| @squares[[x,y]].piece ? @squares[[x,y]].piece.unicode : " "}.join(" | ")} |"
      puts "  +---+---+---+---+---+---+---+---+"
    end
    puts "    1   2   3   4   5   6   7   8  "
  end
   
  private

  def line_to_destination_clear?(origin_coords, destination_coords)
    offsets = get_coord_offsets(origin_coords, destination_coords)
    test_coords = origin_coords
    ((offsets[0] != 0 ? offsets[0].abs : offsets[1].abs) - 1).times do
      [0, 1].each {|n| test_coords[n] +=  offsets[n]/(offsets[n].abs) unless offsets[n] == 0}
      return false if @squares[test_coords].piece
    end
    return true   
  end  

  def get_coord_offsets(origin_coords, destination_coords)
    [destination_coords[0] - origin_coords[0], destination_coords[1] - origin_coords[1]]
  end

  def get_destination_coords(origin_coords, offsets)
    [origin_coords[0] + offsets[0], origin_coords[1] + offsets[1]]
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
