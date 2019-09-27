require_relative "lib/board" 
require 'io/console' 

@board = Board.new

def get_valid_entry
  while true
    entry = gets.chomp.downcase
    return entry.to_sym if [:save, :load, :quit, :""].include?(entry.to_sym)
    if /[a-h]\d\s[a-h]\d/ === entry
      entry = entry.split.map {|coords| coords = coords.split("")}.each do |coords|
        coords[0] = coords[0].ord - 96
        coords[1] = coords[1].to_i
      end
      return entry if @board.legal_move?(entry[0].dup, entry[1].dup)
    end
    puts "Invalid Entry"
    puts "Entry options are save, load, quit or the origin and destination "
    puts "coordinates of a #{@board.turn_color.to_s} colored piece you wish to move."
    print "\n#{@board.turn_color.capitalize}'s turn: "
  end
end
  
def startup_display
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

def turn_display
  puts "#{@board.turn_color.capitalize}'s turn"
  puts "Enter the coordinates of the piece you would like to move."
  puts "followed by the destination coordinates for your piece."
  puts "Make sure to leave a space between the two coordinates."
  puts "Example: a2 a3"
  print "\n#{@board.turn_color.capitalize}'s turn: "
end

def exicute_entry(player_entry)
  case player_entry
  when :save
    @board.save 
  when :load
    @board.load
  when :""
    nil
  else
    @board.move(player_entry[0], player_entry[1])
  end
end

while true
  @board = Board.new
  startup_display
  player_entry = get_valid_entry
  exicute_entry(player_entry) unless player_entry == :quit
  until @board.get_result || player_entry == :quit
    @board.display
    puts "** You are in check, you must move to protect your king! **" if @board.get_checked_color
    turn_display
    player_entry = get_valid_entry
    exicute_entry(player_entry) unless player_entry == :quit
  end
  break if player_entry == :quit
  puts @board.get_result == :draw ? "The game is a draw" : "#{@board.get_result.to_s.capitalize} Wins!"
  puts "press any key to return to the start menu"
  STDIN.getch
end