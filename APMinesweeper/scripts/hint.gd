extends Resource
class_name Hint

var existingHints : Array[NetworkHint]
var allLocations : Array[APLocation]

func grant_hint() -> void:
	if not Archipelago.is_ap_connected(): return
	Archipelago.conn.install_hint_listener()
	existingHints = Archipelago.conn.hints
	allLocations = Archipelago.conn.locations.values()
	for h in existingHints:
		allLocations.pop_at(h.item.loc_id)
	var locationID = allLocations.pick_random().id
	print(allLocations.size())
	Archipelago.conn.scout(locationID, 1, Callable())
