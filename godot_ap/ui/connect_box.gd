extends GridContainer

@export var ipbox: LineEdit
@export var portbox: LineEdit
@export var slotbox: LineEdit
@export var pwdbox: LineEdit
@export var errlbl: Label

func _ready() -> void:
	Archipelago.creds.updated.connect(refresh_creds)
	refresh_creds(Archipelago.creds)
	Archipelago.connected.connect(func(_conn,_json): update_connection(true))
	Archipelago.disconnected.connect(func(): update_connection(false))
func refresh_creds(creds: APCredentials) -> void:
	ipbox.text = creds.ip
	portbox.text = creds.port
	slotbox.text = creds.slot
	pwdbox.text = creds.pwd

func update_connection(status: bool) -> void:
	ipbox.editable = not status
	portbox.editable = not status
	slotbox.editable = not status
	pwdbox.editable = not status
func try_connection() -> void:
	if Archipelago.is_not_connected():
		Archipelago.ap_connect(ipbox.text, portbox.text, slotbox.text, pwdbox.text)
		_connect_signals()

func kill_connection() -> void:
	Archipelago.ap_disconnect()

func _connect_signals() -> void:
	if not Archipelago.connected.is_connected(_on_connect_success):
		Archipelago.connected.connect(_on_connect_success)
	if not Archipelago.connectionrefused.is_connected(_on_connect_refused):
		Archipelago.connectionrefused.connect(_on_connect_refused)
func _disconnect_signals() -> void:
	Archipelago.connected.disconnect(_on_connect_success)
	Archipelago.connectionrefused.disconnect(_on_connect_refused)
func _on_connect_success(_conn: ConnectionInfo, _json: Dictionary) -> void:
	_disconnect_signals()
	errlbl.text = ""
func _on_connect_refused(_conn: ConnectionInfo, json: Dictionary) -> void:
	_disconnect_signals()
	errlbl.text = "ERROR: " + (", ".join(json.get("errors", ["Unknown"])))
