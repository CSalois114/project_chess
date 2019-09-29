require_relative "lib/board" 
require 'io/console' 

while true
  board = Board.new
  board.display_startup
  player_entry = board.get_valid_entry
  board.exicute_entry(player_entry) unless player_entry == :quit
  until board.get_result || player_entry == :quit
    board.display_board
    board.display_check if board.get_checked_color
    board.display_turn
    player_entry = board.get_valid_entry
    board.exicute_entry(player_entry) unless player_entry == :quit
  end
  break if player_entry == :quit
  board.display_board
  board.display_result
  puts "Press any key to return to the start menu"
  STDIN.getch
end