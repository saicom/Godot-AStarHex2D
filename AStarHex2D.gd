extends RefCounted
class_name AStarHex2D

var astar = AStar2D.new()
var tile_map: TileMap
var region: Rect2i

const DIRECTIONS = [
	Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 1),
	Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, -1),
]


func _init(_tile_map: TileMap, obstacle_layer: int):
	tile_map = _tile_map
	region = tile_map.get_used_rect()
	_create_points_graph()
	_set_obstacle_layer(obstacle_layer)

func _set_obstacle_layer(layer: int):
	for x in range(region.position.x, region.position.x + region.size.x):
		for y in range(region.position.y, region.position.y + region.size.y):
			var tile_pos = Vector2i(x, y)
			if not tile_map.get_cell_tile_data(layer, tile_pos):
				continue
			set_point_solid(tile_pos, true)

func _create_points_graph():
	for x in range(region.position.x, region.position.x + region.size.x):
		for y in range(region.position.y, region.position.y + region.size.y):
			var tile_pos = Vector2i(x, y)
			if not _is_valid_tile(tile_pos):
				continue
			var point_id = _get_point_uid(tile_pos)
			astar.add_point(point_id, tile_map.map_to_local(tile_pos))
	
	for point_id in astar.get_point_ids():
		var tile_pos = tile_map.local_to_map(astar.get_point_position(point_id))
		for dir in DIRECTIONS:
			var neighbor = tile_pos + dir
			if _is_valid_tile(neighbor):
				var neighbor_id = _get_point_uid(neighbor)
				if not astar.are_points_connected(point_id, neighbor_id):
					astar.connect_points(point_id, neighbor_id)


func _is_valid_tile(tile_pos: Vector2i):
	return region.has_point(tile_pos) and tile_map.get_cell_tile_data(0, tile_pos) != null


func _get_point_uid(tile_pos: Vector2i):
	return tile_pos.x + tile_pos.y * region.size.x + 100000
	

func find_path(start: Vector2i, end: Vector2i) -> Array:
	var start_id = _get_point_uid(start)
	var end_id = _get_point_uid(end)
	
	return astar.get_point_path(start_id, end_id)


func global_to_map(global_pos: Vector2):
	return tile_map.local_to_map(tile_map.to_local(global_pos))


func set_point_solid(pos: Vector2i, is_solid: bool):
	var point_id = _get_point_uid(pos)
	astar.set_point_disabled(point_id, is_solid)
