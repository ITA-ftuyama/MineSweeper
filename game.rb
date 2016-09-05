require 'gosu'
require_relative "engine/mine_sweeper"
require_relative "gui/simple_printer"
require_relative "gui/pretty_printer"
require 'matrix'

class GameWindow < Gosu::Window

  def initialize
    @window_width = 800
    @window_height = 600
    super @window_width, @window_height
    self.caption = "Campo Minado"

    @width, @height, @num_mines = 10, 20, 100
    @game = Minesweeper.new @width, @height, @num_mines
    @board = @game.board_state
  end

  def needs_cursor?
    true
  end

  def update
    # Updates the game content according the user input
    if Gosu::button_down? Gosu::MsLeft or Gosu::button_down? Gosu::MsRight then
      # Core loop game adapted
      if @game.still_playing?
        x = self.mouse_x / @square_width
        y = self.mouse_y / @square_height
        # Possible plays according input
        if Gosu::button_down? Gosu::MsLeft and @game.play(x, y)
          @board = @game.board_state
        end
        if Gosu::button_down? Gosu::MsRight and @game.flag(x, y)
          @board = @game.board_state
        end
      else
        # Game Over
        if @game.victory?
          beep = Gosu::Sample.new("media/victory.wav")
        else
          beep = Gosu::Sample.new("media/gameover.wav")
        end
        beep.play
        @board = @game.board_state(xray: true)
      end
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end

  def draw
    # Draws the game
    draw_board()
    for i in 0..@width - 1
      for j in 0..@height - 1
        print_square(@board[i, j], i, j)
      end
    end
  end

  def draw_board()
    # Draws basic board
    @square_width = @window_width / @width
    @square_height = @window_height / @height
    draw_quad(
      0,        0,        0xff33aaaa,
      @window_width,  0,        0xff33aaaa,
      0,        @window_height, 0xff33aaaa,
      @window_width,  @window_height, 0xff33aaaa,
    0)
    for i in 0..@height
      draw_line(
        0,        i * @square_height, 0xff000000,
        @window_width,  i * @square_height, 0xff000000,
      0)
    end
    for j in 0..@width
      draw_line(
        j * @square_width, 0,         0xff000000,
        j * @square_width, @window_height,  0xff000000,
      0)
    end
  end

  def print_square(square, i, j)
    # Prints square content
    case square
    when 0 # Undiscovered square
      return
    when -1 # Blank discovered square
      highlight(i, j)
      return
    when -4 # Mine revealed after defeat
      @message = Gosu::Image.new("media/skull.png")
    when -3 # Flag marked
      @message = Gosu::Image.new("media/flag.png")
    when -2 # Mine was discovered
      @message = Gosu::Image.new("media/redskull.png")
    else # Discovered square indicating danger
      highlight(i, j)
      @message = Gosu::Image.from_text(self, @board[i, j], Gosu.default_font_name, 28)
    end
    @message.draw((i + 0.3)* @square_width, j * @square_height, 0)
  end

  def highlight(i, j)
    # Highlight discovered square
    x = i * @square_width - 1
    y = j * @square_height - 1
    draw_quad(
      x + 1,          y + 1,          0xff66cccc,
      x + @square_width - 1,  y + 1,          0xff66cccc,
      x + 1,          y + @square_height - 1, 0xff66cccc,
      x + @square_width - 1,  y + @square_height - 1, 0xff66cccc,
    0)
  end

end

window = GameWindow.new
window.show

# Bypass the private nature of that method
class Matrix
  def []=(row, column, value)
    @rows[row][column] = value
  end
end
