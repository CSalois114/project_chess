require "./lib/piece.rb"

describe Piece do
  it "sets its color and returns it with #color" do
    white_king = Piece.new("\u2654")
    black_king = Piece.new("\u265A")

    expect(white_king.color).to eql(:white)
    expect(black_king.color).to eql(:black)
  end

  it "sets offsets correctly" do
    king       = Piece.new("\u2654")
    queen      = Piece.new("\u265B")
    rook       = Piece.new("\u2656")
    bishop     = Piece.new("\u265D")
    knight     = Piece.new("\u2658")
    white_pawn = Piece.new("\u2659")
    black_pawn = Piece.new("\u265F")

    expect(king.move_offsets.include?([1, 1])).to          be true
    expect(king.move_offsets.include?([2, 1])).to          be false
    expect(king.move_offsets.include?([0, 0])).to          be false

    expect(queen.move_offsets.include?([7, 7])).to         be true
    expect(queen.move_offsets.include?([-7, -7])).to       be true
    expect(queen.move_offsets.include?([1, 3])).to         be false

    expect(rook.move_offsets.include?([0, 4])).to          be true
    expect(rook.move_offsets.include?([0, -4])).to         be true
    expect(rook.move_offsets.include?([1, -4])).to         be false

    expect(bishop.move_offsets.include?([-1, -1])).to      be true
    expect(bishop.move_offsets.include?([-7, 7])).to       be true
    expect(bishop.move_offsets.include?([0, 0])).to        be false

    expect(knight.move_offsets.include?([-1, -2])).to      be true
    expect(knight.move_offsets.include?([1, 2])).to        be true
    expect(knight.move_offsets.include?([2, 2])).to        be false

    expect(white_pawn.move_offsets.include?([0, 1])).to    be true
    expect(white_pawn.move_offsets.include?([-1, 1])).to   be true
    expect(white_pawn.move_offsets.include?([0, -1])).to   be false

    expect(black_pawn.move_offsets.include?([0, -1])).to   be true
    expect(black_pawn.move_offsets.include?([0, -2])).to   be true
    expect(black_pawn.move_offsets.include?([0, 1])).to    be false
  end
end

