require_relative "piece"
require_relative "square"

class Board

  def initialize
    @squares = {}
    (1..8).each{|x| (1..8).each{|y| @squares[ [x, y] ] = Square.new([x,y]) } }
    set_pieces_for_new_game
  end

  def display 
    system("clear") || system("cls")
    puts "    1   2   3   4   5   6   7   8  "
    puts "  +---+---+---+---+---+---+---+---+"
    (1..8).each do |y|  #puts each row of the board
      puts "#{y} | #{(1..8).map{|x| @squares[[x,y]].piece ? @squares[[x,y]].piece.unicode : " "}.join(" | ")} |"
      puts "  +---+---+---+---+---+---+---+---+"
    end
    puts "    1   2   3   4   5   6   7   8  "
  end

  private

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
