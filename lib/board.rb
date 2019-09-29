require_relative "piece"
require_relative "square"
require_relative "saving"
require_relative "display"

class Board
  include Saving
  include Display

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
    change_pawn_in_end(destination_coords)
  end

  def legal_move?(origin_coords, destination_coords, ignore_turn_color=false, display_error=true)
    unless @squares[origin_coords] && @squares[destination_coords]
      puts "ERROR: Invalid Coordinates" if display_error
      return false  
    end
    unless @squares[origin_coords].piece
      puts "ERROR: There is no piece there to move" if display_error
      return false  
    end
    move_offsets = get_coord_offsets(origin_coords, destination_coords)
    piece = @squares[origin_coords].piece
    unless (@squares[origin_coords].piece.color == @turn_color || ignore_turn_color)
      puts "ERROR: You can only move #{@turn_color.capitalize} pieces" if display_error
      return false
    end
    unless piece.move_offsets.include?(move_offsets)
      puts "ERROR: That piece can't move like that" if display_error
      return false
    end
    if @squares[destination_coords].piece
      if piece.color == @squares[destination_coords].piece.color
        puts "ERROR: You can't attack your own piece" if display_error
        return false
      end
      if ["\u2659", "\u265F"].include?(piece.unicode) && [[0,1], [0,2], [0,-1], [0,-2]].include?(move_offsets)
        puts "ERROR: Pawns can only attack diagonally" if display_error
        return false
      end
    end
    if ["\u2655", "\u265B", "\u2656", "\u265C", "\u2657", "\u265D"].include?(piece.unicode) &&
        get_squares_between(origin_coords, destination_coords).any? {|square| square.piece}
      puts "ERROR: There is a piece in the way of that move" if display_error
      return false
    end
    if (piece.unicode == "\u2659" && move_offsets == [0, 2] && origin_coords[1] != 2) || 
       (piece.unicode == "\u265F" && move_offsets == [0, -2] && origin_coords[1] != 7)
      puts "ERROR: Pawns can only move two spaces from their starting square" if display_error
      return false
    end
    if moving_into_check?(origin_coords, destination_coords)
      puts "ERROR: Your King can't be left in check" if display_error
      return false
    end
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
  
  def get_valid_entry
    while true
      entry = gets.chomp.downcase
      return entry.to_sym if [:save, :load, :quit, :""].include?(entry.to_sym)
      if /[a-h]\d\s[a-h]\d/ === entry
        entry = entry.split.map {|coords| coords = coords.split("")}.each do |coords|
          coords[0] = coords[0].ord - 96
          coords[1] = coords[1].to_i
        end
        return entry if legal_move?(entry[0], entry[1])
      end
      display_invalid_entry
    end
  end
    
  def exicute_entry(player_entry)
    case player_entry
    when :save
      save 
    when :load
      load
    when :""
      nil
    else
      move(player_entry[0], player_entry[1])
    end
  end

  private

  def change_pawn_in_end(coords)
    piece_color = @squares[coords].piece.color
    if [1, 8].include?(coords[1]) && ["\u2659", "\u265F"].include?(@squares[coords].piece.unicode)
      case get_desired_piece_type
      when :queen
        @squares[coords].piece = piece_color == :white ? Piece.new("\u2655") : Piece.new("\u265B")
      when :rook
        @squares[coords].piece = piece_color == :white ? Piece.new("\u2656") : Piece.new("\u265C")
      when :bishop
        @squares[coords].piece = piece_color == :white ? Piece.new("\u2657") : Piece.new("\u265D")
      when :knight
        @squares[coords].piece = piece_color == :white ? Piece.new("\u2658") : Piece.new("\u265E")
      end
    end
  end
      
  def get_desired_piece_type
    display_board
    display_pawn_upgrade
    piece = gets.chomp.downcase.to_sym
    until [:queen, :rook, :bishop, :knight].include?(piece)
      display_invalid_pawn_upgrade
      piece = gets.chomp.downcase.to_sym
    end
    piece
  end

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
