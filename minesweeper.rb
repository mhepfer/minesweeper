class Board
  attr_reader :board
  
  def initialize
    @board = Array.new(9) { Array.new(9, '*')} # Tile.new
    @bomb_locations = []
    create_bombs
    tiles = Tile.new(@bomb_locations)
  end
  
  def create_bombs
    bomb_count = rand(5..15)
    
    until bomb_count == 0
      @bomb_locations << [ rand(9), rand(9) ]
      bomb_count -= 1
    end
    
    # iterate over @bomb_locations
    # @board[position].place_bomb
    p @bomb_locations
  end
  
  def all_bombs_revealed?
    tiles_left = 0
    
    @board.each do |row|
      row.each do |tile|
        tiles_left += 1 if (tile == '*' || tile == 'F')
      end
    end
       
    tiles_left == @bomb_locations.length 
  end
  
  def print
    @board.each do |row|
      p row
    end
  end
  
end

class Tile
  NEIGHBOR_OFFSETS = [[1,1], [1,0], [1,-1], [0,-1], [-1,-1], [-1,0], [-1,1], [0,1]]
  
  def initialize(bomb_locations)
    @bomb_board = Array.new(9) { Array.new(9, 0)}
    @bomb_locations = bomb_locations
    fill_bomb_numbers
    fill_bombs
    print
  end
  
  def fill_bombs
    @bomb_locations.each do |coords|
      @bomb_board[coords.first][coords.last] = 'B'
    end
  end
  
  def fill_bomb_numbers
    @bomb_locations.each do |coords|
      x = coords.first
      y = coords.last
      NEIGHBOR_OFFSETS.each do |offset|
        offset_x = offset.first
        offset_y = offset.last
        new_x, new_y = x + offset_x, y + offset_y
        unless new_x < 0 || new_x > 8 || new_y < 0 || new_y > 8
          @bomb_board[new_x][new_y] += 1
        end
      end
    end
  end
  
  def print
    @bomb_board.each do |row|
      p row
    end
  end
  
end


class Player
  
  def initialize
    @move = []
    @board = Board.new
  end
  
  def inspect
    if @explored
    else
      "*"
    end
  end
  
  def play_game
    
    game_over = false
    
    until game_over
      @board.print
      get_move
      reveal_updated_board
      game_over = check_game_over
    end
  end
  
  def check_game_over
    #if player picked bomb
    if @board.bomb_locations.include?(move)
      print "You hit a bomb! You lose."
      return true 
    end
    
    if @board.all_bombs_revealed?
      print "You win! You found all the bombs."
      return true
    end
    
    false
    #all bombs revealed
  end
  
  def get_move
    p "Would you like to flag (f) or reveal (r) a tile? "
    flag_or_reveal = gets.chomp
    
    p "which space? x, y"
    @move = gets.chomp.split(",")
    
    if flag_or_reveal == 'r'
      reveal_tile(@move)
    else
      flag_tile(@move)
    end
    
  end
end

player = Player.new
player.play_game


=begin
method

return found a number
method(left)
method(right)
method(up)
method(down)
=end