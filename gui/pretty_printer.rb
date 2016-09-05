require 'matrix'

class PrettyPrinter
	def print_board(board)
		puts "#Campo Minado"
		for i in -1..board.row_size()
			for j in -1..board.column_size()
				# Prints a moldure to the game
				if i == -1 or i == board.row_size() or 
					j == -1 or j == board.column_size()
					print '#'
				# Maps the Matrix values into chars
				else
					case board[i, j]
					when 0
						print '-'
					when -1
						print ' '
					when -2
						print '@'
					when -3
						print 'F'
					when -4
						print '*'
					else
						print board[i, j]
					end
				end
			end
			puts ''
		end
	end
end

# Bypass the private nature of that method
class Matrix
  def []=(row, column, value)
    @rows[row][column] = value
  end
end