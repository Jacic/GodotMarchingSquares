extends Node2D

class_name VoxelGrid

signal updateNeighbors(cX, cY)

var numRows:int
var numColumns:int
var chunkX:int
var chunkY:int
var chunkSize:int

var dummyX:Voxel
var dummyY:Voxel
var dummyT:Voxel

var xNeighbor
var yNeighbor
var xyNeighbor

var grid_map = []
var voxels = []
var polygons = []
var cellSize = 8

var showGrid:bool = false
var showDots:bool = false
var dotContainer:Control = null
var dots = []

func _init(cX:int, cY:int, rows:int, columns:int):
	chunkX = cX
	chunkY = cY
	numRows = rows
	numColumns = columns
	chunkSize = (rows + 1) * cellSize
	position = Vector2(cX * chunkSize, cY * chunkSize)

	dummyX = Voxel.new(Vector2.ZERO, 0.0)
	dummyY = Voxel.new(Vector2.ZERO, 0.0)
	dummyT = Voxel.new(Vector2.ZERO, 0.0)

# Generate a grid containing coordinates
func generateChunk():
	# We are adding +1 since the grid_map are the "dots" that decide whether or not it is filled
	for x in range(0, numRows+1):
		# Creating a multi dimentional array
		grid_map.append([])
		voxels.append([])
		for y in range(0, numColumns+1):
			var rand_int = int(randf() < 0.6)
			
			# Store value in grid_map
			grid_map[x].append(rand_int)
			voxels[x].append(Voxel.new(Vector2(x * cellSize, y * cellSize), cellSize))
			voxels[x][y].state = grid_map[x][y]
	
	setupPolys()

# Draws dots that indicate whether or not an area is filled 
func drawDots():
	if dotContainer:
		dotContainer.visible = true
		return
	
	dotContainer = Control.new()
	dotContainer.set_name("dot_container")
	add_child(dotContainer)
	
	var dot = ImageTexture.new()
	dot.load("res://assets/voxel.png")
	
	for x in range(0, numColumns+1):
		dots.append([])
		for y in range(0, numRows+1):
			var sprite = Sprite.new()
			sprite.set_texture(dot)
			if(grid_map[x][y] == 0):
				sprite.modulate.r = 0.0
				sprite.modulate.g = 0.0
				sprite.modulate.b = 0.0
			sprite.position = Vector2(x * cellSize, y * cellSize)
			
			dots[x].append(sprite)
			dotContainer.add_child(sprite)

func hideDots():
	if dotContainer:
		dotContainer.visible = false

func addPoly(vec:Array):
	var p = Polygon2D.new()
	p.set_polygon(PoolVector2Array(vec))
	add_child(p)
	polygons.append(p)

func addPentagon(a:Vector2, b:Vector2, c:Vector2, d:Vector2, e:Vector2):
	var p1 = Polygon2D.new()
	p1.set_polygon(PoolVector2Array([a, b, c]))
	add_child(p1)
	polygons.append(p1)
	var p2 = Polygon2D.new()
	p2.set_polygon(PoolVector2Array([a, c, d]))
	add_child(p2)
	polygons.append(p2)
	var p3 = Polygon2D.new()
	p3.set_polygon(PoolVector2Array([a, d, e]))
	add_child(p3)
	polygons.append(p3)

func addQuad(a:Vector2, b:Vector2, c:Vector2, d:Vector2):
	var p1 = Polygon2D.new()
	p1.set_polygon(PoolVector2Array([a, b, c]))
	add_child(p1)
	polygons.append(p1)
	var p2 = Polygon2D.new()
	p2.set_polygon(PoolVector2Array([a, c, d]))
	add_child(p2)
	polygons.append(p2)

func addTriangle(a:Vector2, b:Vector2, c:Vector2):
	var p = Polygon2D.new()
	p.set_polygon(PoolVector2Array([a, b, c]))
	add_child(p)
	polygons.append(p)

func setupPolys():
	for p in polygons:
		p.queue_free()
	polygons.clear()
	
	if xNeighbor != null:
		dummyX.duplicateVoxelX(xNeighbor.voxels[0][0], chunkSize)

	for y in numRows:
		for x in numColumns:
			var a = voxels[x][y]  		# Top left
			var b = voxels[x+1][y] 		# Top right
			var c = voxels[x][y+1] 		# Bottom left
			var d = voxels[x+1][y+1] 	# Bottom right
			
			triangulateCell(a, b, c, d)
	
		if xNeighbor != null:
			triangulateGapCell(y)
	
	if yNeighbor != null:
		triangulateGapRow()

func triangulateCell(a:Voxel, b:Voxel, c:Voxel, d:Voxel):
	var state = (a.state) + (b.state * 2) + (c.state * 4) + (d.state * 8)
			
	match(state):
		1:
			addTriangle(a.position, a.yEdge, a.xEdge)
		2:
			addTriangle(b.position, a.xEdge, b.yEdge)
		3:
			addQuad(a.position, a.yEdge, b.yEdge, b.position)
		4:
			addTriangle(c.position, c.xEdge, a.yEdge)
		5:
			addQuad(a.position, c.position, c.xEdge, a.xEdge)
		6:
			addTriangle(b.position, a.xEdge, b.yEdge)
			addTriangle(c.position, c.xEdge, a.yEdge)
		7:
			addPentagon(a.position, c.position, c.xEdge, b.yEdge, b.position)
		8:
			addTriangle(d.position, b.yEdge, c.xEdge)
		9:
			addTriangle(a.position, a.yEdge, a.xEdge)
			addTriangle(d.position, b.yEdge, c.xEdge)
		10:
			addQuad(a.xEdge, c.xEdge, d.position, b.position)
		11:
			addPentagon(b.position, a.position, a.yEdge, c.xEdge, d.position)
		12:
			addQuad(a.yEdge, c.position, d.position, b.yEdge)
		13:
			addPentagon(c.position, d.position, b.yEdge, a.xEdge, a.position)
		14:
			addPentagon(d.position, b.position, a.xEdge, a.yEdge, c.position)
		15:
			addQuad(a.position, c.position, d.position, b.position)
		_:	#0
			pass

func triangulateGapRow():
	dummyY.duplicateVoxelY(yNeighbor.voxels[0][0], chunkSize)

	for x in numRows:
		var swap:Voxel = dummyT
		swap.duplicateVoxelY(yNeighbor.voxels[x + 1][0], chunkSize)
		dummyT = dummyY
		dummyY = swap
		triangulateCell(voxels[x][numRows], voxels[x + 1][numRows], dummyT, dummyY)
	
	if xNeighbor != null:
		dummyT.duplicateVoxelXY(xyNeighbor.voxels[0][0], chunkSize)
		triangulateCell(voxels[numRows][numColumns], dummyX, dummyY, dummyT)

func triangulateGapCell(y:int):
	var swap:Voxel = dummyT
	swap.duplicateVoxelX(xNeighbor.voxels[0][y + 1], chunkSize)
	dummyT = dummyX
	dummyX = swap
	triangulateCell(voxels[numColumns][y], dummyT, voxels[numColumns][y + 1], dummyX)

func updateVoxel(voxelPos:Vector2):
	var state = !voxels[voxelPos.x][voxelPos.y].state
	voxels[voxelPos.x][voxelPos.y].state = state
	if dotContainer:
		if state:
			dots[voxelPos.x][voxelPos.y].modulate.r = 1.0
			dots[voxelPos.x][voxelPos.y].modulate.g = 1.0
			dots[voxelPos.x][voxelPos.y].modulate.b = 1.0
		else:
			dots[voxelPos.x][voxelPos.y].modulate.r = 0.0
			dots[voxelPos.x][voxelPos.y].modulate.g = 0.0
			dots[voxelPos.x][voxelPos.y].modulate.b = 0.0

func updateChunk():
	setupPolys()

# Draws background line grid
func _draw():
	if(showGrid):
		var color = Color(0,0,0)
		var thickness = 1
		for x in range(0, numColumns+1):
			for y in range(0, numRows+1):
				draw_line(Vector2(x*cellSize,y*cellSize), Vector2((x+1)*cellSize,y*cellSize), color, thickness)
				draw_line(Vector2((x+1)*cellSize,y*cellSize), Vector2((x+1)*cellSize,(y+1)*cellSize), color, thickness)
				draw_line(Vector2(x*cellSize,y*cellSize), Vector2(x*cellSize,(y+1)*cellSize), color, thickness)
				draw_line(Vector2(x*cellSize,(y+1)*cellSize), Vector2((x+1)*cellSize,(y+1)*cellSize), color, thickness)

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.pressed:
		var clickPos:Vector2 = get_viewport().canvas_transform.affine_inverse().xform(event.position) - get_global_position()
		var voxelPos:Vector2 = Vector2(floor((clickPos.x + cellSize / 2) / cellSize), floor((clickPos.y + cellSize / 2) / cellSize))
		if voxelPos.x >= 0 && voxelPos.x < numColumns + 1 && voxelPos.y >= 0 && voxelPos.y < numRows + 1:
			updateVoxel(voxelPos)
			updateChunk()
			if voxelPos.x == 0 || voxelPos.x == numColumns || voxelPos.y == 0 || voxelPos.y == numRows:
				emit_signal("updateNeighbors", chunkX, chunkY)
