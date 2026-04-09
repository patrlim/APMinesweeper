extends MarginContainer

# The different "pages"
@export var difficultyScreen : Node
@export var difficultyContainer : Node
@export var minesweeperScreen : Node

# The thing that contains the tiles
@onready var minesweeperGrid : GridContainer = $MinesweeperScreen/ScrollContainer/Minefield

# Topbar controls
@onready var quitButton : Button = $MinesweeperScreen/TopBar/Button
@onready var mineCounter : Label = $MinesweeperScreen/TopBar/MineCounter
@onready var flagCounter : Label = $MinesweeperScreen/TopBar/FlagCounter

# Difficulty list
@export var difficulties : Array[Difficulty]
@export var deathlink : Deathlink
var hint : Hint = Hint.new()

@export var assets : MinesweeperAssets
var game : Minesweeper = Minesweeper.new()

func on_win() -> void:
	hint.grant_hint()
	pass

func on_loss() -> void:
	deathlink.send_deathlink()
	pass

func _ready() -> void:
	game.set_assets(assets)
	game.update_flag_count.connect(update_flag_count)
	quitButton.pressed.connect(switch_to_difficulty_select)
	setup_difficulty_select()
	switch_to_difficulty_select()
	game.won.connect(on_win)
	game.lost.connect(on_loss)
	return

func update_flag_count() -> void:
	flagCounter.text = str(game.difficulty.minecount - game.usedFlags) + " flags"

func update_mine_count() -> void:
	mineCounter.text = str(game.difficulty.minecount) + " mines"
	
func setup_difficulty_select() -> void:
	for difficulty in difficulties:
		var dimensionsLabel : Label = Label.new()
		dimensionsLabel.text = str(difficulty.width) + " x " + str(difficulty.height)
		difficultyContainer.add_child(dimensionsLabel)
		
		var minecountLabel : Label = Label.new()
		minecountLabel.text = str(difficulty.minecount) + "mines"
		difficultyContainer.add_child(minecountLabel)
		
		var difficultyButton : DifficultyButton = DifficultyButton.new(difficulty, difficulty.name)
		difficultyButton.difficulty_chosen.connect(pick_difficulty)
		difficultyContainer.add_child(difficultyButton)

func set_minefield_width() -> void:
	minesweeperGrid.set_columns(game.difficulty.height)

func pick_difficulty(difficulty : Difficulty) -> void:
	game.clear_previous_game(minesweeperGrid)
	game.set_difficulty(difficulty)
	game.initialize_board()
	set_minefield_width()
	game.append_tiles_to_parent(minesweeperGrid)
	update_flag_count()
	update_mine_count()
	switch_to_game_board()
	return

func switch_to_difficulty_select() -> void:
	difficultyScreen.show()
	minesweeperScreen.hide()
	return
	
func switch_to_game_board() -> void:
	difficultyScreen.hide()
	minesweeperScreen.show()
	return
