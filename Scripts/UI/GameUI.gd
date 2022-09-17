extends Control

# Player 1 related canvas
onready var player1_bomb_count := $Player1/Bomb/GrayArea/Count as Label
onready var player1_fire_count := $Player1/Fire/GrayArea/Count as Label
onready var player1_label := $Player1/Label as Label
onready var player1_panel := $Player1 as Panel
onready var death_label := $SuddenDeathLabel
onready var animation_player:= $AnimationPlayer

# Player 2 related canvas
onready var player2_bomb_count := $Player2/Bomb/GrayArea/Count as Label
onready var player2_fire_count := $Player2/Fire/GrayArea/Count as Label
onready var player2_label := $Player2/Label as Label
onready var player2_panel := $Player2 as Panel



func _ready():
	EventManager.connect("update_item_canvas", self, "update_player_items")
	death_label.visible = false
	
func start_sudden_death() -> void:
	death_label.visible = true
	animation_player.play("blink")
	
func update_player_items(bomb_amount: int, bomb_range: int, player_type: int) -> void:
	match player_type:
		0:
			player1_bomb_count.text = str(bomb_amount)
			player1_fire_count.text = str(bomb_range)
		1:
			pass
			player2_bomb_count.text = str(bomb_amount)
			player2_fire_count.text = str(bomb_range)



func set_player_canvas_colors(player_type: int, new_color: Color) -> void:
	match player_type:
		0:
			player1_label.add_color_override("font_color", new_color)
			player1_panel.set_self_modulate(new_color) 
		1:
			player2_label.add_color_override("font_color", new_color)
			player2_panel.set_self_modulate(new_color)



func set_death_label_visibility(value: bool):
	death_label.visible=value
