require 'test/unit'
require_relative "mine_sweeper"

class MinesweeperTest < Test::Unit::TestCase

  def setup
    # MineSweeper
    @minesweeper = Minesweeper.new 3, 4, 5
    @mboard = @minesweeper.instance_variable_get("@mines_board")
    @board = @minesweeper.instance_variable_get("@display_board")

    # TinyMS
    @tinyMS = Minesweeper.new 2, 2, 1
    @mines_board = @tinyMS.instance_variable_get("@mines_board")
    @display_board = @tinyMS.instance_variable_get("@display_board")
    @mines_board = Matrix.zero(2, 2)
    @mines_board[1, 1] = 1
    @display_board[0, 0] =  1	# Visible
    @display_board[1, 0] = -1	# Visible
    @display_board[0, 1] =  0	# Hidden  : Game not completed yet
    @tinyMS.instance_variable_set("@mines_board", @mines_board)
    @tinyMS.instance_variable_set("@display_board", @display_board)
  end

  def teardown

  end

  #
  # => Testing MineSweeper Public API
  #

  def test_initialize
    # Given
    # initial condition
    # When
    minesweeper = Minesweeper.new 3, 4, 5
    # Then
    board = minesweeper.instance_variable_get("@mines_board")
    assert_equal(3, board.row_size())
    assert_equal(4, board.column_size())
    assert_equal(5, board.inject(:+))
  end

  def test_flag
    # Given
    @board[0, 0] =  0	# Hidden square
    @board[1, 1] = -3	# Placed flag
    @board[0, 1] = -1	# Visible square
    @board[1, 0] = -2	# Visible mine
    @board[2, 2] =  3	# Visible square

    # When
    assert_equal(true,  @minesweeper.flag(0,0))
    assert_equal(true,  @minesweeper.flag(1,1))
    assert_equal(false, @minesweeper.flag(0,1))
    assert_equal(false, @minesweeper.flag(1,0))
    assert_equal(false, @minesweeper.flag(2,2))

    # Then
    assert_equal(-3, @board[0, 0]) # Flag placed
    assert_equal( 0, @board[1, 1]) # Flag displaced
    assert_equal(-1, @board[0, 1])
    assert_equal(-2, @board[1, 0])
    assert_equal( 3, @board[2, 2])
  end

  def test_victory_true
    # Given
    # initial condition

    ### One square reamining to be discovered ###
    # When
    # Then
    assert_equal(false, @tinyMS.victory?)

    ### Discovering last square ###
    # When
    @display_board[0, 1] = 1		# Visible  : Game is now completed
    # Then
    assert_equal(true, @tinyMS.victory?)

    ### Flagging the remaining mine ###
    # When
    @display_board[1, 1] = -3	# Flagging mine  : Game is now completed
    # Then
    assert_equal(true, @tinyMS.victory?)

    ### Clicking the mine ###
    # When
    @display_board[1, 1] = -2	# Clicking mine  : Game is now lost
    # Then
    assert_equal(false, @tinyMS.victory?)
  end

  def test_victory_false
    # Given
    # initial condition

    ### Remaining square to be discovered is flagged ###
    # When
    @display_board[0, 1] = -3	# Flagged  : Game not completed yet
    # Then
    assert_equal(false, @tinyMS.victory?)

    ### Remaining square is discovered ###
    # When
    @display_board[0, 1] =-1		# Visible  : Game is now completed
    # Then
    assert_equal(true, @tinyMS.victory?)
  end

  def test_still_playing
    # Given
    # initial condition

    ### Brand new game ###
    # When
    # Then
    assert_equal(true, @minesweeper.still_playing?)

    ### One square reamining to be discovered ###
    # When
    # Then
    assert_equal(true, @tinyMS.still_playing?)

    ### Discovering last square ###
    # When
    @display_board[0, 1] = 1		# Visible  : Game is now completed
    # Then
    assert_equal(false, @tinyMS.still_playing?)

    ### Flagging the remaining mine ###
    # When
    @display_board[1, 1] = -3	# Flagging mine  : Game is now completed
    # Then
    assert_equal(false, @tinyMS.still_playing?)

    ### Clicking the mine ###
    # When
    @display_board[1, 1] = -2	# Clicking mine  : Game is now lost
    # Then
    assert_equal(false, @tinyMS.still_playing?)
  end

  def test_board_state
    # Given
    # initial condition
    # When
    returned_board = @minesweeper.board_state
    # Then
    assert_equal(@board, returned_board)
    assert_equal(false, (returned_board.include? -4))
  end

  def test_board_state_with_parameter
    # Given
    @display_board[0, 1] = 1		# Visible  : Game is now completed

    ### Complete board is shown ###
    # When
    returned_board = @tinyMS.board_state(xray: true)
    # Then
    assert_not_equal(@display_board, returned_board)
    assert_equal(true, (returned_board.include? -4))

    ### Complete board is not shown ###
    # When
    returned_board = @tinyMS.board_state(xray: false)
    # Then
    assert_equal(@display_board, returned_board)
    assert_equal(false, (returned_board.include? -4))
  end

  def test_play_invalid
    # Given
    # initial condition

    # When
    @display_board[0, 0] = -4
    # Then
    assert_equal(false, @tinyMS.play(0, 0))

    # When
    @display_board[0, 0] = -3
    # Then
    assert_equal(false, @tinyMS.play(0, 0))

    # When
    @display_board[0, 0] = -2
    # Then
    assert_equal(false, @tinyMS.play(0, 0))

    # When
    @display_board[0, 0] = -1
    # Then
    assert_equal(false, @tinyMS.play(0, 0))

    # When
    @display_board[0, 0] = 1
    # Then
    assert_equal(false, @tinyMS.play(0, 0))
  end

  def test_play_invalid1
    assert_equal(false, @tinyMS.play(0, 0))
    assert_equal(false, @tinyMS.play(1, 0))
    assert_equal(true,  @tinyMS.play(0, 1))	# Game is over
    assert_equal(false, @tinyMS.play(1, 1))
  end

  def test_play_invalid2
    assert_equal(false, @tinyMS.play(0, 0))
    assert_equal(false, @tinyMS.play(1, 0))
    assert_equal(true,  @tinyMS.play(1, 1))  # Game is over
    assert_equal(false, @tinyMS.play(0, 1))
  end

  def test_play_valid
    # Given
    # initial conditionb
    # When
    @display_board[0, 0] = 0
    @display_board[1, 0] = -3
    # Then
    assert_equal(true, @tinyMS.play(0, 0))
    assert_equal(1, @display_board[0, 0])
    assert_equal(1, @display_board[1, 0])
    assert_equal(1, @display_board[0, 1])
    assert_equal(true, @tinyMS.victory?)
  end

  def test_play_complex
    # Given
    mboard = @minesweeper.instance_variable_get("@mines_board")
    mboard = Matrix[[0, 0, 1, 0],
                    [0, 0, 1, 0],
                    [0, 1, 1, 1]]
    @minesweeper.instance_variable_set("@mines_board", mboard)

    # When
    assert_equal(true, @minesweeper.play(0, 0))

    # Then
    assert_equal(-1, @board[0, 0])
    assert_equal( 4, @board[1, 1])
    assert_equal( 1, @board[2, 0])
    assert_equal( 0, @board[0, 2])
    assert_equal( 0, @board[1, 2])
    assert_equal( 0, @board[0, 3])
    assert_equal( 0, @board[1, 3])
  end

  def test_initialize_with_failure
    assert_raise() {
      Minesweeper.new 3, -1, 5
    }
    assert_raise() {
      Minesweeper.new -3, 1, 5
    }
    assert_raise() {
      Minesweeper.new 3, 1, 0
    }
  end

end
