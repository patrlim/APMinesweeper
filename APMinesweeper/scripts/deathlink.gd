extends Resource
class_name Deathlink

@export var deathMessages = [
	" skipped school.",
	" didn't play Lethal Company.",
	" found a funny button.",
	" went everywhere.",
	" can't count.",
	" failed a 50/50.",
	" found a mine.",
	" fucked up."
]

func send_deathlink() -> void:
	if not Archipelago.is_deathlink(): return
	var playerName : String = Archipelago.creds.slot
	var deathMessage : String = deathMessages.pick_random()
	Archipelago.conn.send_deathlink(playerName + deathMessage)
