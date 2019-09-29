require_relative "lib/board" 
require 'io/console' 

def get_valid_entry
  while true
    entry = gets.chomp.downcase
    return entry.to_sym if [:save, :load, :quit, :""].include?(entry.to_sym)
    if /[a-h]\d\s[a-h]\d/ === entry
      entry = entry.split.map {|coords| coords = coords.split("")}.each do |coords|
        coords[0] = coords[0].ord - 96
        coords[1] = coords[1].to_i
      end
      return entry if @board.legal_move?(entry[0], entry[1])
    end
    @board.display_invalid_entry
  end
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
  @board.display_startup
  player_entry = get_valid_entry
  exicute_entry(player_entry) unless player_entry == :quit
  until @board.get_result || player_entry == :quit
    @board.display_board
    @board.display_check if @board.get_checked_color
    @board.display_turn
    player_entry = get_valid_entry
    exicute_entry(player_entry) unless player_entry == :quit
  end
  break if player_entry == :quit
  @board.display_board
  @board.display_result
  puts "Press any key to return to the start menu"
  STDIN.getch
end