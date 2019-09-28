require "./lib/board.rb"

describe Board do
  describe "#move" do
    it "moves a piece to a new square, removing any piece at the destination" do
      board = Board.new

      expect(board.squares[[5, 1]].piece.unicode).to eql("\u2654")
      expect(board.squares[[4, 1]].piece.unicode).to eql("\u2655")

      board.move([5, 1], [4, 1])

      expect(board.squares[[4, 1]].piece.unicode).to eql("\u2654")
      expect(board.squares[[5, 1]].piece).to be nil
    end
    
    it "flips the turn_color each time a move is made" do
      board = Board.new

      expect(board.turn_color).to eql(:white)

      board.move([1, 2], [1, 3])

      expect(board.turn_color).to eql(:black)
      
      board.move([1, 3], [1, 4])

      expect(board.turn_color).to eql(:white)
    end

    it "upgrades pawn when pawn reaches other sied" do
      board = Board.new
      allow($stdout).to receive(:puts)
      board.squares.values.each {|square| square.piece = nil}
      board.squares[[1, 2]].piece = Piece.new("\u265f") #black pawn
      board.squares[[1, 7]].piece = Piece.new("\u2659") #white pawn
      allow(board).to receive(:gets).and_return("queen")
      board.move([1, 2], [1, 1])
      board.move([1, 7], [1, 8])

      expect(board.squares[[1, 1]].piece.unicode).to eql("\u265B")
      expect(board.squares[[1, 8]].piece.unicode).to eql("\u2655")
    end
  end 

  describe "#legal_move?" do
    it "returns false when no piece is selected" do
      board = Board.new
      expect(board.legal_move?([1, 5], [1, 6], true)).to be false
    end

    it "returns false when the origin or destination square doesn't exist" do
      board = Board.new
      expect(board.legal_move?([8, 1], [9, 1], true)).to be false
      expect(board.legal_move?([9, 3], [8, 3], true)).to be false
    end

    it "returns false if destination is not included in move offsets for that piece" do
      board = Board.new
      expect(board.legal_move?([1, 2], [1, 5], true)).to be false
      expect(board.legal_move?([2, 1], [4, 3], true)).to be false
    end

    it "handles pawn doulble move only from base line" do
      board = Board.new
      board.squares[[1,5]].piece = Piece.new("\u2659")
      expect(board.legal_move?([1, 2], [1, 4], true)).to be true
      expect(board.legal_move?([1, 5], [1, 7], true)).to be false
      expect(board.legal_move?([2, 7], [2, 5], true)).to be true
    end

    it "doesnt allow pieces to attack their own color" do
      board = Board.new
      expect(board.legal_move?([5, 1], [5, 2], true)).to be false
      expect(board.legal_move?([2, 1], [4, 2], true)).to be false
    end

    it "only allows pawns to attack on diagnal" do
      board = Board.new
      board.squares[[3,3]].piece = Piece.new("\u265F")
      board.squares[[4,4]].piece = Piece.new("\u265F")
      expect(board.legal_move?([3, 2], [3, 3], true)).to be false
      expect(board.legal_move?([4, 2], [4, 4], true)).to be false
      expect(board.legal_move?([4, 2], [3, 3], true)).to be true
    end
    
    it "doesn't let the queens, rooks, or bishops jump over pieces" do
      board = Board.new
      (1..8).each {|x| board.squares[[x,7]].piece = nil}

      expect(board.legal_move?([1, 1], [1, 3], true)).to be false
      expect(board.legal_move?([1, 8], [1, 3], true)).to be true
      expect(board.legal_move?([1, 8], [1, 2], true)).to be true

      expect(board.legal_move?([3, 1], [1, 3], true)).to be false
      expect(board.legal_move?([3, 8], [1, 6], true)).to be true
      
      expect(board.legal_move?([4, 1], [4, 3], true)).to be false
      expect(board.legal_move?([4, 8], [4, 3], true)).to be true
    end

    it "doesn't allow you to move into check" do
      board = Board.new
      board.squares[[1, 5]].piece = Piece.new("\u2654")
      board.squares[[5, 7]].piece = nil
      
      expect(board.legal_move?([1, 5], [1, 4], true)).to be true
      expect(board.legal_move?([1, 5], [1, 6], true)).to be false
      expect(board.legal_move?([1, 5], [2, 5], true)).to be true
      expect(board.legal_move?([1, 5], [2, 4], true)).to be false
      expect(board.legal_move?([5, 8], [5, 7], true)).to be true
    end

    it "doesn't allow you to expose your king to check" do 
      board = Board.new
      board.squares[[3, 3]].piece = Piece.new("\u265B") #black queen

      expect(board.legal_move?([4, 2], [4, 3], true)).to be false
    end
  end
  
  describe "#get_checked_color" do
    it "returns nil if no king is in check" do
      board = Board.new

      expect(board.get_checked_color).to be nil
    end

    it "returns the color of the king in check" do
      board = Board.new
      board.squares.values.each {|square| square.piece = nil}
      board.squares[[1, 1]].piece = Piece.new("\u2654") #white king
      board.squares[[3, 3]].piece = Piece.new("\u265A") #black king
      board.squares[[2, 2]].piece = Piece.new("\u265B") #black queen

      expect(board.get_checked_color).to eql(:white)

      board.squares[[2, 2]].piece = Piece.new("\u2655") #white queen

      expect(board.get_checked_color).to eql(:black)
    end
  end

  describe "#get_checkmated_color" do
    it "returns nil when no king in checkmate" do
      board = Board.new

      expect(board.get_checkmated_color).to be nil
    end

    it "returns nil when the king can move out of check" do
      board = Board.new
      board.squares[[5, 1]].piece = nil 
      board.squares[[5, 6]].piece = Piece.new("\u2654") #white king

      expect(board.get_checkmated_color).to be nil
    end

    it "returns nil when there is only one attacking piece and it can be killed" do 
      board = Board.new
      board.squares[[6, 2]].piece = nil
      board.squares[[7, 3]].piece = Piece.new("\u265B") #black queen

      expect(board.get_checked_color).to eql(:white)

      expect(board.get_checkmated_color).to be nil
    end

    it "returns nil when there is only one attacking piece and it can be blocked" do
      board = Board.new
      board.squares[[6, 2]].piece = nil
      board.squares[[8, 4]].piece = Piece.new("\u265B") #black queen

      expect(board.get_checked_color).to eql(:white)

      expect(board.get_checkmated_color).to be nil
    end

    it "returns the color of the king in checkmate" do
      board = Board.new
      board.squares[[1, 4]].piece = Piece.new("\u2655") #white queen
      board.squares[[5, 8]].piece = nil
      board.squares[[5, 3]].piece = Piece.new("\u265A") #black king
      
      expect(board.get_checkmated_color).to eql(:black)
    end
  end

  describe "get_result" do
    it "returns nil when there is no winner" do
      board = Board.new

      expect(board.get_result).to be nil
    end

    it "returns the winning color when a king is in checkmate" do
      board = Board.new
      board.squares[[5, 1]].piece = nil
      board.squares[[2, 4]].piece = Piece.new("\u265B")
      board.squares[[1, 6]].piece = Piece.new("\u2654")

      expect(board.get_result).to eql(:black)

      board = Board.new
      board.squares[[5, 8]].piece = nil
      board.squares[[2, 5]].piece = Piece.new("\u2655")
      board.squares[[1, 3]].piece = Piece.new("\u265A")

      expect(board.get_result).to eql(:white)
    end
    
    it "returns :draw if there are only the two kings left" do
      board = Board.new
      board.squares.values.each {|square| square.piece = nil}
      board.squares[[1, 1]].piece = Piece.new("\u2654")
      board.squares[[8, 8]].piece = Piece.new("\u265A")

      expect(board.get_result).to eql(:draw)
    end
  end
end
