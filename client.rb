require_relative "engine/mine_sweeper"
require_relative "gui/simple_printer"
require_relative "gui/pretty_printer"

width, height, num_mines = 10, 20, 100
game = Minesweeper.new width, height, num_mines
play = 0

while game.still_playing?
  if play % 2 == 0
    valid_move = game.play(rand(width), rand(height))
  else
    valid_flag = game.flag(rand(width), rand(height))
  end
  if valid_move or valid_flag
    printer = (rand > 0.5) ? SimplePrinter.new : PrettyPrinter.new
    printer.print_board(game.board_state)
  end
  play += 1
end

puts "Fim do jogo!"
if game.victory?
  puts "Você venceu!"
else
  puts "Você perdeu! As minas eram:"
  PrettyPrinter.new.print_board(game.board_state(xray: true))
end
