module Display  
   
  def display_board
    system("clear") || system("cls")
    puts "    a   b   c   d   e   f   g   h  "
    puts "  +---+---+---+---+---+---+---+---+"
    (1..8).reverse_each do |y|  #puts each row of the board
      puts "#{y} | #{(1..8).map{|x| @squares[[x,y]].piece ? @squares[[x,y]].piece.unicode : " "}.join(" | ")} |"
      puts "  +---+---+---+---+---+---+---+---+"
    end
    puts "    a   b   c   d   e   f   g   h  "
  end

  def display_startup
    system("clear") || system("cls")
    puts "###################################"
    puts "#####                         #####"
    puts "###            CHESS            ###"
    puts "#####                         #####"
    puts "###################################"
    puts "\n            Start  Menu"
    puts "This game is controled using any of"
    puts "the following commands:"
    puts "save - saves the current game"
    puts "load - load a saved game"
    puts "quit - exits the game"
    puts "These commands can be entered at"
    puts "any time throughout the game."
    puts "\nEnter a command now or press enter"
    puts "to begin a new game."
    print "player entry: "
  end
  
  def display_turn
    puts "*#{@turn_color.capitalize}'s turn"
    puts "Example Move: a2 a3"
    print "\n#{@turn_color.capitalize}'s move: "
  end

  def display_pawn_upgrade
    puts "Your pawn has made it to the other side!"
    puts "Enter the name of the piece you would like to replace it with."
    puts "Your options are: queen, rook, bishop, or knight"
    print "Piece type: "
  end

  def display_invalid_entry
    puts "\nMove options are save, load, quit or your move coordinates."
    puts "Move coordinates should be seperated by a space."
  end

  def display_check 
    puts "** You are in check, you must move to protect your king! **" 
  end

  def display_invalid_pawn_upgrade
    puts "Invalid entry"
    puts "Please enter queen, rook, bishop, or knight."
  end

  def display_result
    puts get_result == :draw ? "The game is a draw" : "CHECKMATE! #{get_result.to_s.capitalize} Wins!"
  end
end