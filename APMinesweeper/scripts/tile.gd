extends BaseButton
class_name Tile

var mined : bool
var covered : bool
var flagged : bool
var neighbors : int
var tilepos : Vector2i

var gamestate

enum state {
	LOST,
	PLAYING,
	WON
}
var assets : MinesweeperAssets

signal uncover(tilepos : Vector2i)
signal flag(tilepos : Vector2i)

func _init( pos : Vector2i, a : MinesweeperAssets) -> void:
	mined = false
	covered = true
	flagged = false
	gamestate = state.PLAYING
	neighbors = 0
	tilepos = pos
	
	assets = a
	
	set_texture_filter(TEXTURE_FILTER_NEAREST)
	set_custom_minimum_size(Vector2(32,32))

func reset_to_default() -> void:
	mined = false
	covered = true
	flagged = false
	gamestate = state.PLAYING

func set_won():
	gamestate = state.WON
	queue_redraw()

func set_lost():
	gamestate = state.LOST
	queue_redraw()

func is_covered() -> bool:
	return covered

func clicked() -> void:
	uncover.emit(tilepos)

func reveal() -> void:
	if flagged:
		flag.emit(tilepos)
	covered = false
	queue_redraw()

func toggle_flag() -> void:
	flagged = not flagged
	queue_redraw()

func set_mine() -> void:
	mined = true
	queue_redraw()

func _draw() -> void:
	if gamestate == state.PLAYING:
		if covered:
			draw_raised()
			if flagged:
				draw_flagged()
		else:
			draw_depressed()
			draw_neigbors()
	if gamestate == state.LOST:
		if covered:
			if mined:
				if not flagged:
					draw_depressed()
					draw_mine()
				else:
					draw_raised()
					draw_flagged()
			else:
				if flagged:
					draw_depressed()
					draw_crossed_out()
				else:
					draw_raised()
		else:
			if mined:
				draw_red()
				draw_exploded()
			else:
				draw_depressed()
				draw_neigbors()
	
	if gamestate == state.WON:
		if covered:
			draw_raised()
			draw_flagged()
		else:
			draw_depressed()
			draw_neigbors()

func draw_red() -> void:
	draw_rect(Rect2(0,0,32,32), Color(1.0, 0.0, 0.0, 1.0))

func draw_crossed_out() -> void:
	draw_texture_rect(assets.crossedOutMine, Rect2(0, 0, 32, 32), false)

func draw_mine() -> void:
	draw_texture_rect(assets.mine, Rect2(0, 0, 32, 32), false)

func draw_exploded() -> void:
	draw_texture_rect(assets.mineExploded, Rect2(0, 0, 32, 32), false)

func draw_flagged() -> void:
	draw_texture_rect(assets.flag, Rect2(0, 0, 32, 32), false)

func draw_neigbors() -> void:
	if neighbors > 0:
		draw_texture_rect(assets.numbers[neighbors], Rect2(0, 0, 32, 32), false)

func draw_depressed() -> void:
	draw_texture_rect(assets.depressedTile, Rect2(0, 0, 32, 32), false)

func draw_raised() -> void:
	draw_texture_rect(assets.raisedTile, Rect2(0, 0, 32, 32), false)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gui_input.connect(_on_Button_gui_input)

# black magic from stackoverflow
func _on_Button_gui_input(event) -> void:
	if event is InputEventMouseButton and event.pressed and gamestate == state.PLAYING:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				clicked()
			MOUSE_BUTTON_RIGHT:
				flag.emit(tilepos)
