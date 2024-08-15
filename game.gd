extends Node2D

@onready var tile_map: TileMap = $TileMap
@onready var player: Sprite2D = $Player

var path_finder: AStarHex2D

var path = []
var cur_target_index = 0
var speed: float = 200

func _ready() -> void:
	path_finder = AStarHex2D.new(tile_map, 1)
	player.global_position = tile_map.to_global(tile_map.map_to_local(Vector2i(6, 3)))
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var start_pos = path_finder.global_to_map(player.global_position)
		var end_pos = path_finder.global_to_map(tile_map.get_global_mouse_position())
		var tmp_path = path_finder.find_path(start_pos, end_pos)
		print(tmp_path)
		
		path.clear()
		cur_target_index = 1
		for point in tmp_path:
			path.append(tile_map.to_global(point))
		
func _process(delta: float) -> void:
	if path.size() == 0:
		return
		
	if cur_target_index < path.size():
		var target_pos = path[cur_target_index]
		var distance = speed * delta
		player.global_position = player.global_position.move_toward(target_pos, distance)
		if player.global_position.distance_to(target_pos) <= distance:
			cur_target_index += 1
			player.global_position = target_pos
