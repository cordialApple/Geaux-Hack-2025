extends Node

var num = 3
var player_name: String = ""

var players: Array = []
var bot_target_count: int = 5
var _next_id: int = 0

func register_player(body, is_bot: bool) -> int:
	var id := _next_id
	_next_id += 1
	var entry := {
		"id": id,
		"body": body,
		"is_bot": is_bot,
		"score": 0,
		"tier": body.animal_tier if "animal_tier" in body else 0,
	}
	players.append(entry)
	return id

func deregister_player(body) -> void:
	for i in range(players.size() - 1, -1, -1):
		if players[i].body == body:
			players.remove_at(i)
			return

func get_bots() -> Array:
	return players.filter(func(p): return p.is_bot)

func get_humans() -> Array:
	return players.filter(func(p): return not p.is_bot)

func get_bot_count() -> int:
	return get_bots().size()
