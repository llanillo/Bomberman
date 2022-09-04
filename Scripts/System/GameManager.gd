extends Node2D

class_name GameManager

const TileSize := 32
const TileMapBrickindex := 0

onready var bricks_tile_map := $BricksTileMap
onready var game_ui := $GameUI
onready var start_game_timer := $StartGameTimer
onready var timer_label := $TimerLabel
onready var player0 := $Player 
onready var player1 := $Player2

export (PackedScene) var game_over_ui_scene := preload("res://Scenes/UI/GameOverUI.tscn")

var player0_sprite_frame : SpriteFrames
var player1_sprite_frame : SpriteFrames
var player0_color : Color
var player1_color : Color

export (Dictionary) var tiles_scenes := {
	0: preload("res://Scenes/Environment/UndestructibleBrick.tscn"),
	1: preload("res://Scenes/Environment/DestructibleBrick.tscn")}

# TODO REPLACE WITH SPRITE FRAMES FILES
export (Dictionary) var players_sprite_frames := {}
#	0: preload(),
#	1: preload(),
#	2: preload(),
#	3: preload()}

export (Dictionary) var player_colors := {
	0: Color.aliceblue,
	1: Color.aliceblue,
	2: Color.aliceblue,
	3: Color.aliceblue}
	
# Called when the node enters the scene tree for the first time.
func _ready():
	EventManager.connect("player_die", self, "show_game_over")
	timer_label.add_color_override("font_color", Color(randf(), randf(), randf()))
	start_game_timer.connect("timeout", self, "restart_game")
	start_game_timer.start()
	# TODO UNCOMMENT
#	set_random_color_to_player()
#	set_player_canvas_colors(0, player0_color)
#	set_player_canvas_colors(1, player1_color)
#	player0.set_sprite_frame(player0_sprite_frame)
#	player1.set_sprite_frame(playaer1_sprite_frame


#	yield(get_tree(), "idle_frame") # Neccesary to avoid TileMap crashes # TODO TEST if removing still works
	replace_tiles_with_scene_objects(bricks_tile_map, tiles_scenes)



func _process(delta):
	timer_label.text = (str(int(start_game_timer.time_left + 1)))
	
	
	
func show_game_over(losing_player: int) -> void:
	if !GameStatus.can_play: return
	
	var game_over_ui_instance = game_over_ui_scene.instance()
	var winner_player
	
	if losing_player == 0:
		winner_player = 1
	else:
		winner_player = 0
		
	add_child(game_over_ui_instance)
	game_over_ui_instance.set_winner_label_text(winner_player + 1, Color.blueviolet) # TODO: replace color
	GameStatus.can_play = false
	


func restart_game() -> void:
	# Allows player movements
	GameStatus.can_play = true
	timer_label.visible = false
	
	# Initial player canvas values
	game_ui.update_player_items(1, 1, 0)
	game_ui.update_player_items(1, 1, 1)


# TODO : Add to ready function
func set_random_color_to_player(player) -> void:
	var first_number = NumberUtil.get_random_number_in_range(0, player_colors.size(), -1)
	var second_number = NumberUtil.get_random_number_in_range(0, player_colors.size(), first_number)
	player0_color = player_colors[first_number]
	player1_color = player_colors[second_number]
	player0_sprite_frame = players_sprite_frames[first_number]
	player1_sprite_frame = players_sprite_frames[second_number]



func replace_tiles_with_scene_objects(tile_map: TileMap, scenes_dicitionary: Dictionary) -> void:
	for tile_pos in tile_map.get_used_cells():
		var tile_id := tile_map.get_cell(tile_pos.x, tile_pos.y)
		
		if scenes_dicitionary.has(tile_id):
			var object_scene = scenes_dicitionary[tile_id]
			# Clear the cell in the tilemap
			if tile_map.get_cellv(tile_pos) != tile_map.INVALID_CELL:
				tile_map.set_cellv(tile_pos, -1) # Removes the tile cell
				tile_map.update_bitmask_region() # Updates the tile map to avoid conflict
				
			# Spawn the object at the position
			if object_scene:
				var object_instance = object_scene.instance()
				var object_position := tile_map.map_to_world(tile_pos) + tile_map.cell_size * 0.5
				object_instance.global_position = object_position
				add_child(object_instance)

	
