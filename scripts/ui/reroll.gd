extends Button

func _process(delta: float) -> void:
	var rerolls = SessionManager.session["reroll"]
	text = "Reroll (" + str(rerolls) + ")"
	disabled = rerolls <= 0
