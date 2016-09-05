require 'matrix'

class Minesweeper

  # Mines_Board is a matrix where:
  # 0 -> blank square
  # 1 -> planted mine
  @mines_board
  # Display_Board is a matrix where:
  #-4 -> planted mine (only pos-game)
  #-3 -> placed flag
  #-2 -> discovered mine
  #-1 -> blank square (visible)
  # 0 -> blank square (hidden)
  #>0 -> blank square (visible)
  #      indicating nearby mines
  @display_board

  def initialize(height, width, num_mines)
    # Check for valid parameters
    if height <= 0 or width <= 0 or num_mines <= 0
      raise "Bad initialization parameters"
    end
    @height, @width, @num_mines = height, width, num_mines
    generate_board()
  end

  def still_playing?
    # Check victory and defeat conditions
    return !(victory? or @display_board.include? -2)
  end

  def victory?
    # Defeat condition
    if @display_board.include? -2
      return false
    end
    # Counts visible squares on board
    visible_squares = 0
    for i in 0..@height - 1
      for j in 0..@width - 1
        if @display_board[i, j] == -1 or @display_board[i, j] > 0
          visible_squares += 1
        end
      end
    end
    # Check if this number is equal total blank squares
    return visible_squares == @height * @width - @num_mines
  end

  def board_state(*args)
    # Check xray argument
    if args.length == 1 and !still_playing?
      if args[0][:xray]
        return complete_board()
      end
    end
    return @display_board
  end

  def play(x, y)
    # Check if play is valid
    if @display_board[x, y] != 0 or !still_playing?
      return false
    end
    # Check if mine was found
    if @mines_board[x, y] == 1
      @display_board[x, y] = -2
    else
      show_square(x, y)
    end
    return true
  end

  def flag(x, y)
    square = @display_board[x, y]
    # If it's a flag or hidden square
    if square == -3 or square == 0
      # Flag into hidden square OR hidden square into flag
      @display_board[x, y] = square.abs - 3
      return true
    end
    return false
  end

  private
  # Generate initial board position
  def generate_board()
    @display_board = Matrix.zero(@height, @width)
    @mines_board = Matrix.zero(@height, @width)
    # Generating mines on random position
    for i in 1..@num_mines
      begin
        row, column = rand(@height), rand(@width)
      end until @mines_board[row, column] != 1
      @mines_board[row, column] = 1
    end
  end

  private
  # Recursive function to show squares
  def show_square(x, y)
    if @mines_board[x, y] == 0 and
      (@display_board[x, y] == 0 or @display_board[x, y] == -3)
      # Blank/Flagged squares are now visible
      nearby_mines = 0
      @display_board[x, y] = -1
      # Expand nearby squares counting nearby mines
      for i in -1..1
        for j in -1..1
          if in_range(x + i, y + j)
            show_square(x + i, y + j)
            nearby_mines += @mines_board[x + i, y + j]
          end
        end
      end

      # Display nearby mines amount
      if nearby_mines != 0
        @display_board[x, y] = nearby_mines
      end
    end
  end

  private
  # Verifies if the position is on board range
  def in_range(x, y)
    return (x >= 0 and y >= 0 and x < @height and y < @width)
  end

  private
  # Show complete board, display_board with mines
  def complete_board()
    board = @display_board.clone
    for row in 0..@height - 1
      for column in 0..@width - 1
        if @mines_board[row, column] == 1
          if board[row, column] != -2
            board[row, column] = -4
          end
        end
      end
    end
    return board
  end
end

# Bypass the private nature of that method
class Matrix
  def []=(row, column, value)
    @rows[row][column] = value
  end
end
