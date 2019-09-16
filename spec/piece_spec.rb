require "./lib/piece.rb"

describe Piece do
 it "sets its color and returns it with #color" do
  white_king = Piece.new("2654")
  black_king = Piece.new("265A")
  expect(white_king.color).to eql(:white)
  expect(black_king.color).to eql(:black)
 end
end

