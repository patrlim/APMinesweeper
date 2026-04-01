class_name Minesweeper
extends Resource

var board : Dictionary[Vector2i, Tile] = {}
var difficulty : Difficulty = null
var usedFlags : int = 0
var generated : bool = false
var assets : MinesweeperAssets = null

var offsets = [
	Vector2i(-1, 1),
	Vector2i(0, 1),
	Vector2i(1, 1),
	Vector2i(-1, 0),
	Vector2i(1, 0),
	Vector2i(-1, -1),
	Vector2i(0, -1),
	Vector2i(1, -1)
]

signal won()
signal lost()
signal update_flag_count()

func set_assets(a : MinesweeperAssets) -> void:
	assets = a

func set_difficulty(d : Difficulty) -> void:
	difficulty = d

func clear_previous_game(parent : Node) -> void:
	for tile in parent.get_children():
		parent.remove_child(tile)
	generated = false
	usedFlags = 0
	difficulty = null
	board = {}

func check_win() -> bool:
	for x in range(difficulty.width):
		for y in range(difficulty.height):
			var mineCoordinate = Vector2i(x, y)
			if board[mineCoordinate].covered and not board[mineCoordinate].mined:
				return false
	return true

func append_tiles_to_parent(parent : Node) -> void:
	for x in range(difficulty.width):
		for y in range(difficulty.height):
			var mineCoordinate = Vector2i(x, y)
			parent.add_child(board[mineCoordinate])

func initialize_board() -> void:
	board.clear()
	for x in range(difficulty.width):
		for y in range(difficulty.height):
			var mineCoordinate = Vector2i(x, y)
			board[mineCoordinate] = Tile.new(mineCoordinate, assets)
			board[mineCoordinate].uncover.connect(uncover_tile)
			board[mineCoordinate].flag.connect(flag_tile)

func flag_tile(tilePos : Vector2i) -> void:
	if board[tilePos].covered:
		if board[tilePos].flagged or (difficulty.minecount > usedFlags):
			board[tilePos].toggle_flag()
			var delta : int = 1 if board[tilePos].flagged else -1
			usedFlags += delta
			update_flag_count.emit()

func calculate_neigbors(tilePos : Vector2i) -> int:
	var count : int = 0
	for offset in offsets:
		var checkPos = tilePos + offset
		if not board.has(checkPos):
			continue
		if board[checkPos].mined:
			count += 1
	return count

func calculate_neigbor_flags(tilePos : Vector2i) -> int:
	var count : int = 0
	for offset in offsets:
		var checkPos = tilePos + offset
		if not board.has(checkPos):
			continue
		if board[checkPos].flagged:
			count += 1
	return count

func inform_mines_of_fail() -> void:
	for x in range(difficulty.width):
		for y in range(difficulty.height):
			var mineCoordinate = Vector2i(x, y)
			board[mineCoordinate].set_lost()
			

func board_solvable(tilePos : Vector2i) -> bool:
	return true

func uncover_tile(tilePos : Vector2i) -> void:
	if board[tilePos].flagged: return
	if not generated:
		generate_board(tilePos)
		while not board_solvable(tilePos):
			generate_board(tilePos)
		generated = true
	
	board[tilePos].reveal()
	
	if board[tilePos].mined:
		inform_mines_of_fail()
		lost.emit()
		return
	
	if check_win():
		won.emit()
		for x in range(difficulty.width):
			for y in range(difficulty.height):
				var pos : Vector2i = Vector2i(x, y)
				board[pos].set_won()
		
		return
	
	if board[tilePos].neighbors == calculate_neigbor_flags(tilePos):
		for offset in offsets:
			var revealPos = tilePos + offset
			if not board.has(revealPos):
				continue
			if board[revealPos].is_covered() and not board[revealPos].flagged:
				board[revealPos].reveal()
				if board[revealPos].neighbors == 0:
					board[revealPos].clicked()
	
	if board[tilePos].neighbors == 0:
		for offset in offsets:
			var revealPos = tilePos + offset
			if not board.has(revealPos):
				continue
			if board[revealPos].is_covered():
				board[revealPos].reveal()
				board[revealPos].clicked()
	
	return

func random_position() -> Vector2i:
	return Vector2i(randi() % difficulty.width, randi() % difficulty.height)

func neigbors( a : Vector2i, b : Vector2i) -> bool:
	if a == b:
		return true
	for offset in offsets:
		if a + offset == b:
			return true
	return false

func generate_board(clickedTile : Vector2i) -> void:
	for x in range(difficulty.width):
		for y in range(difficulty.height):
			var pos : Vector2i = Vector2i(x, y)
			board[pos].reset_to_default()
	for i in range(difficulty.minecount):
		var minepos = random_position()
		while neigbors(minepos, clickedTile) or board[minepos].mined:
			minepos = random_position()
		board[minepos].set_mine()
	for x in range(difficulty.width):
		for y in range(difficulty.height):
			var mineCoordinate = Vector2i(x, y)
			board[mineCoordinate].neighbors = calculate_neigbors(mineCoordinate)
