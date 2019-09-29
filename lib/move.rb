module Move
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
end