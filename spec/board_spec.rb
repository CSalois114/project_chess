require "./lib/board.rb"

describe Board do
  describe "#legal_non_king_move?" do
    it "returns false when no piece is selected" do
      board = Board.new
      expect(board.legal_non_king_move?([1, 5], [1, 6])).to be false
    end

    it "returns false when the origin or destination square doesn't exist" do
      board = Board.new
      expect(board.legal_non_king_move?([8, 1], [9, 1])).to be false
      expect(board.legal_non_king_move?([9, 3], [8, 3])).to be false
    end

    it "returns false if destination is not included in move offsets for that piece" do
      board = Board.new
      expect(board.legal_non_king_move?([1, 2], [1, 5])).to be false
      expect(board.legal_non_king_move?([2, 1], [4, 3])).to be false
    end

    it "handles pawn doulble move only from base line" do
      board = Board.new
      board.squares[[1,5]].piece = Piece.new("\u2659")
      expect(board.legal_non_king_move?([1, 2], [1, 4])).to be true
      expect(board.legal_non_king_move?([1, 5], [1, 7])).to be false
      expect(board.legal_non_king_move?([2, 7], [2, 5])).to be true
    end

    it "doesnt allow pieces to attack their own color" do
      board = Board.new
      expect(board.legal_non_king_move?([5, 1], [5, 2])).to be false
      expect(board.legal_non_king_move?([2, 1], [4, 2])).to be false
    end

    it "only allows pawns to attack on diagnal" do
      board = Board.new
      board.squares[[3,3]].piece = Piece.new("\u265F")
      board.squares[[4,4]].piece = Piece.new("\u265F")
      expect(board.legal_non_king_move?([3, 2], [3, 3])).to be false
      expect(board.legal_non_king_move?([4, 2], [4, 4])).to be false
      expect(board.legal_non_king_move?([4, 2], [3, 3])).to be true
    end
    
    it "doesn't let the queens, rooks, or bishops jump over pieces" do
      board = Board.new
      (1..8).each {|x| board.squares[[x,7]].piece = nil}

      expect(board.legal_non_king_move?([1, 1], [1, 3])).to be false
      expect(board.legal_non_king_move?([1, 8], [1, 3])).to be true
      expect(board.legal_non_king_move?([1, 8], [1, 2])).to be true

      expect(board.legal_non_king_move?([3, 1], [1, 3])).to be false
      expect(board.legal_non_king_move?([3, 8], [1, 6])).to be true
      
      expect(board.legal_non_king_move?([4, 1], [4, 3])).to be false
      expect(board.legal_non_king_move?([4, 8], [4, 3])).to be true
    end
  end
  describe "#legal_king_move?" do
    it "doesn't allow you to move into check" do
      board = Board.new
      board.squares[[1, 5]].piece = Piece.new("\u2654")
      board.squares[[5, 7]].piece = nil
      expect(board.legal_king_move?([1, 5], [1, 4])).to be true
      expect(board.legal_king_move?([1, 5], [1, 6])).to be false
      expect(board.legal_king_move?([1, 5], [2, 5])).to be true
      expect(board.legal_king_move?([1, 5], [2, 4])).to be false
    end
  end

end