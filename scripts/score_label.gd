extends Label

const KILLS_META_KEY = "enemy_kills"
const KILLS_PER_WAVE_STEP = 20

func _process(delta):
	var current_scene = get_tree().current_scene
	var kills = current_scene.get_meta(KILLS_META_KEY, 0)
	var wave = int(kills / KILLS_PER_WAVE_STEP) + 1
	
	var text_lines = []
	
	text_lines.append("Kills: " + str(kills))
	text_lines.append("Wave: " + str(wave))
	
	if not current_scene.game_started:
		text_lines.append("")
		text_lines.append("Shoot to Start")
	
	if current_scene.game_over:
		text_lines.append("")
		text_lines.append("Press R to Restart")
	
	text = "\n".join(text_lines)
