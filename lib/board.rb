require_relative "piece"
require_relative "square"

class Board
  attr_reader :squares

  def initialize
    @squares = {}
    (1..8).each{|x| (1..8).each{|y| @squares[ [x, y] ] = Square.new([x,y]) } }
    set_pieces_for_new_game
  end

  def legal_non_king_move?(origin_coords, destination_coords)
    return false unless @squares[origin_coords] && @squares[destination_coords] && @squares[origin_coords].piece
    offsets = get_coord_offsets(origin_coords, destination_coords)
    piece = @squares[origin_coords].piece
    return false unless piece.move_offsets.include?(offsets)
    #If the destination square is occupied
    if @squares[destination_coords].piece
      return false if piece.color == @squares[destination_coords].piece.color
      #If the piece is a pawn, it can't attack straight ahead
      return false if ["\u2659", "\u265F"].include?(piece.unicode) && 
        [[0, 1],[0, 2],[0, -1],[0, -2]].include?(offsets)
    end
    #Check for clear line of attack if piece is a queen, rook, or bishop
    if ["\u2655", "\u265B", "\u2656", "\u265C", "\u2657", "\u265D"].include?(piece.unicode)
      return false unless line_to_destination_clear?(offsets, origin_coords)
    end
    #Pawns can only move two spaces if origin_square is the square they start on
    return false if piece.unicode == "\u2659" && offsets == [0, 2] && origin_coords[1] != 2
    return false if piece.unicode == "\u265F" && offsets == [0, -2] && origin_coords[1] != 7

    return true
  end

  def legal_king_move?(origin_coords, destination_coords)
    #See if it's a legal move disregarding if the king will be in check.
    return false unless legal_non_king_move?(origin_coords, destination_coords)
    #Saves destination squares piece if there is one so that it can temporarily be replaced
    #with the moving king to see if it will be in check at the destination.
    destination_current_piece = @squares[destination_coords].piece
    @squares[destination_coords].piece = @squares[origin_coords].piece
    legal = check?(@squares[origin_coords].piece.color, destination_coords) ? false : true
    #Replace the piece that should currently be at the destination.
    @squares[destination_coords].piece = destination_current_piece
    legal
  end

  def check?(king_color, king_coords)
    enemy_squares = @squares.values.select {|square| square.piece.color != king_color if square.piece}
    enemy_squares.each do |square|
      #If any enemy has the potential to attack the king, check if that move is legal.
      if square.piece.move_offsets.include?(get_coord_offsets(square.coords, king_coords))
        return true if legal_non_king_move?(square.coords, king_coords)
      end
    end
    return false
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

  def line_to_destination_clear?(offsets, coords)
    #OBO fix, offsets need to be reduced by one so that the destination square isn't checked.
    offsets.each_with_index do |coord_offset, index|
      offsets[index] -= 1 if coord_offset > 0 
      offsets[index] += 1 if coord_offset < 0 
    end
    #Checks each square in line to destination to see if its occupied.
    until offsets[0] == 0 && offsets[1] == 0 
      [0, 1].each do |index|
        if offsets[index] > 0  
          offsets[index] -= 1
          coords[index] += 1
        end
        if offsets[index] < 0
          offsets[index] += 1
          coords[index] -= 1
        end
      end
      return false if @squares[coords].piece 
    end
    true
  end
      

  def get_coord_offsets(origin_coords, destination_coords)
    [destination_coords[0] - origin_coords[0], destination_coords[1] - origin_coords[1]]
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
