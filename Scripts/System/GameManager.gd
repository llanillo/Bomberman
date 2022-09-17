extends Node2D

class_name GameManager

const TileSize := 32
const TimeBeforeSuddenDeath := 25
const MaximumBombs := 5
const MaximumBombRange := 6
#const TileMapBrickindex := 0

onready var bricks_tile_map := $BricksTileMap
onready var ground_tile_map := $GroundTileMap
onready var game_ui := $GameUI
onready var game_timer := $GameTimer as Timer
onready var sudden_timer :=  $SuddenTimer as Timer
onready var timer_label := $TimerLabel as Label
onready var player1 := $Player0
onready var player2 := $Player1

var change_label = false

export (PackedScene) var game_over_ui_scene := preload("res://Scenes/UI/GameOverUI.tscn")

export (Dictionary) var bricks_tiles_scenes := {
	0: preload("res://Scenes/Environment/DestructibleBrick.tscn"),
	1: preload("res://Scenes/Environment/UndestructibleBrick.tscn")}
export (Dictionary) var ground_tiles_scenes := {
	3: preload("res://Scenes/Environment/DarkSand.tscn"),
	4: preload("res://Scenes/Environment/LightSand.tscn")}


# Called when the node enters the scene tree for the first time.
func _ready():
	EventManager.connect("player_die", self, "show_game_over")
	EventManager.connect("hide_death_label", self, "start_sudden_death_warning")
	PlayerStyle.set_player_random_style()
	timer_label.add_color_override("font_color", Color(randf(), randf(), randf()))
	sudden_timer.connect("timeout", self, "sudden_death_init")
	game_timer.connect("timeout", self, "restart_game")
	game_timer.start()

	# Set colors according to players
	var player1_color := PlayerStyle.get_player1_color()
	var player2_color := PlayerStyle.get_player2_color()
	game_ui.set_player_canvas_colors(0, player1_color)
	game_ui.set_player_canvas_colors(1, player2_color)
	player1.set_label_color(player1_color)
	player2.set_label_color(player2_color)
	player1.set_sprite_frame(PlayerStyle.get_player1_sprite_frame())
	player2.set_sprite_frame(PlayerStyle.get_player2_sprite_frame())

	yield(get_tree(), "idle_frame") # Neccesary to avoid TileMap crashes
	replace_tiles_with_scene_objects(ground_tile_map, ground_tiles_scenes)
	replace_tiles_with_scene_objects(bricks_tile_map, bricks_tiles_scenes)



func _process(delta):
	if change_label:
		timer_label.text = (str(int(sudden_timer.time_left + 1)))
	else:
		timer_label.text = (str(int(game_timer.time_left + 1)))
	
	
func show_game_over(losing_player: int) -> void:
	if !GameStatus.can_play: return
	
	var game_over_ui_instance = game_over_ui_scene.instance()
	var winner_player
	var winner_color
	
	if losing_player == 0:
		winner_player = 2
		winner_color = PlayerStyle.get_player2_color()
	else:
		winner_player = 1
		winner_color = PlayerStyle.get_player1_color()
		
	add_child(game_over_ui_instance)
	game_over_ui_instance.set_winner_label_text(winner_player, winner_color)
	GameStatus.can_play = false
	GameStatus.sudden_death_started = false

	


func restart_game() -> void:
	# Allows player movements
	GameStatus.can_play = true
	GameStatus.sudden_death_started = false
	AudioManager.main_theme.play()
	
	# Initial player canvas values
	game_ui.update_player_items(1, 1, 0)
	game_ui.update_player_items(1, 1, 1)
	
	# Hides players label
	player1.hide_label()
	player2.hide_label()
	
	# Changes timer label
	change_label = true
	
	# Starts sudden death timer
	sudden_timer.start(TimeBeforeSuddenDeath)
	
	
func sudden_death_init() -> void:
	if GameStatus.can_play == true:
		timer_label.visible = false
		game_ui.start_sudden_death()
		GameStatus.sudden_death_started = true
		EventManager.emit_signal("sudden_death_start")
		AudioManager.stop_main_theme()
		AudioManager.play_warning_sound()
	#	EventManager.emit_signal("destroy_all_bricks")


func start_sudden_death_warning() -> void:
	AudioManager.main_theme.stop()
	AudioManager.sudden_death_theme.play()
	game_ui.set_death_label_visibility(false)
	
	

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

	
