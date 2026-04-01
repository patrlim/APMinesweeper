extends Button
class_name DifficultyButton

var difficulty : Difficulty

signal difficulty_chosen(difficulty : Difficulty)

func _init(d : Difficulty, n : String) -> void:
	difficulty = d
	text = n

func _pressed() -> void:
	difficulty_chosen.emit(difficulty)
	
