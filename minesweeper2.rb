require 'debugger'
require 'yaml'

class Board
  NEIGHBOR_OFFSETS = [[1,1], [1,0], [1,-1], [0,-1], [-1,-1], [-1,0], [-1,1], [0,1]]
  attr_reader :grid, :bomb_locations, :neighbors
  
  def initialize()
    @grid = Array.new(9) { |x| Array.new(9) { |y| Tile.new(x,y) }} # Tile.new
    @bomb_locations = []
    @neighbors = []
    create_bombs
    fill_bomb_numbers
  end
  
  def [](pos)
    x, y = pos[0], pos[1]
    @grid[x][y]
  end
  
  def all_bombs_revealed?
    @grid.each do |row|
      row.each do |tile|
        return false if tile.revealed == false && tile.has_bomb == false
      end
    end
    
    true
  end
  
  def create_bombs
    bomb_count = rand(5..15)
    
    until bomb_count == 0
      x,y = rand(9), rand(9)
      @bomb_locations << [x, y] unless @bomb_locations.include?([x,y])
      bomb_count -= 1
    end
    
    @bomb_locations.each do |coords|
      x, y = coords.first, coords.last
      @grid[x][y].has_bomb = true
    end
  end
  
  def fill_bomb_numbers
    
    @bomb_locations.each do |coords|
      x, y = coords.first, coords.last
      
      NEIGHBOR_OFFSETS.each do |offset|
        offset_x = offset.first
        offset_y = offset.last
        new_x, new_y = x + offset_x, y + offset_y
        unless new_x < 0 || new_x > 8 || new_y < 0 || new_y > 8
          @grid[new_x][new_y].count += 1
        end
      end
    end
  end
    
  def reveal_tiles(coords)
    x, y = coords.first, coords.last
    # x, y = coords
    
    self[[x, y]].revealed = true
    return if self[[x, y]].count != 0

    neighbors(coords).each do |neighbor|
      # debugger
      if !neighbor.revealed
        reveal_tiles(neighbor.coords)
      end
    end 
    
  end
  
  def neighbors(coords)
    new_neighbors = []
    x, y = coords.first, coords.last
    NEIGHBOR_OFFSETS.each do |offset|
      offset_x = offset.first
      offset_y = offset.last
      new_x, new_y = x + offset_x, y + offset_y
      unless new_x < 0 || new_x > 8 || new_y < 0 || new_y > 8
        new_neighbors << @grid[new_x][new_y]
        # Consider using local variable & returning it
      end
    end
    new_neighbors
  end
  
  def print_board
    p @bomb_locations.sort
    @grid.each do |row|
      row.each do |tile|
        format_tile( tile )
      end
      puts
    end
  end
  
  def format_tile(tile)
    if tile.flagged
      print 'F'
    elsif tile.revealed && tile.count == 0
      print '_'
    elsif tile.revealed
      print tile.count
    else
      print "*"
    end
  end
  
end

class Tile
  
  attr_accessor :coords, :has_bomb, :count, :revealed, :flagged
  
  def initialize(x,y)
    @coords = [x,y]
    @has_bomb = false
    @count = 0
    @revealed = false
    @flagged = false
  end
  
  def flagged
    @flagged
  end
  
  def [](pos)
    # x, y = pos[0], pos[1]
    # @grid[x][y]
  end
  
end


class Player
  
  def initialize
    @move = []
    @grid = Board.new
  end
  
  def menu
    p "Load a saved game (l) or start a new game (n)?"
    choice = gets.chomp.downcase
    if choice == 'l'
      @grid = YAML::load_file('saved_minesweeper.yml')
      play_game
    else
      new_player = Player.new
      play_game
    end
  end
  
  def play_game
    
    game_over = false
    
    until game_over
      @grid.print_board
      get_move
      game_over = check_game_over
    end
  end
  
  def check_game_over
    #if player picked bomb
    x,y = @move
    if @grid.bomb_locations.include?(@move) && !@grid[@move].flagged
      print "You hit a bomb! You lose."
      return true 
    end
    
    if @grid.all_bombs_revealed?
      print "You win! You found all the bombs."
      return true
    end
    
    false
    #all bombs revealed
  end
  
  def get_move
    p "Flag (f)?, save (s)?, or input the coordinates."
    input = gets.chomp
    
    if input == 'f'
      flagged_move
    elsif input == 's'
      saved_game = @grid.to_yaml
      File.open('saved_minesweeper.yml', 'w') {|f| f.write saved_game}
      p 'Goodbye!'
    else
      reveal_move(input)
    end
  end
  
  def flagged_move
    p "which space? x, y"
    flag_move = gets.chomp.split(",").map(&:to_i)
    # x, y = @move
    cur_flag = @grid[flag_move].flagged
    @grid[flag_move].flagged = (cur_flag == false ? true : false)
  end
  
  def reveal_move(input)
    @move = input.split(",").map(&:to_i)
    x, y = @move
    if x < 0 || x > 8 || y < 0 || y > 8
      p "NOT VALID"
    else
      @grid.reveal_tiles(@move)
    end
  end
  
  def save_game
    #saves game
  end
  
end

player = Player.new
player.menu