extends Node2D

# Grid Properties
export (int) var columns = 6
export (int) var rows = 6
export (int) var numChunksX = 8
export (int) var numChunksY = 8

# Display for Demonstration
export (int, "Nothing", "Only Grid", "Only Dots", "Both") var display = 0 setget setDisplayEditor
var showGrid = true
var showDots = false

var grid_map = []
var voxels = []
var polygons = []
var chunks = []
var cellSize = 16

func _ready():
	randomize()
	generateChunks()
	update_screen()

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventKey:
		if OS.get_scancode_string(event.scancode) == "1":
			setDisplay(0)
		elif OS.get_scancode_string(event.scancode) == "2":
			setDisplay(1)
		elif OS.get_scancode_string(event.scancode) == "3":
			setDisplay(2)
		elif OS.get_scancode_string(event.scancode) == "4":
			setDisplay(3)

func generateChunks():
	for x in numChunksX:
		chunks.append([])
		for y in numChunksY:
			var chunk = VoxelGrid.new(x, y, rows, columns)
			chunk.connect("updateNeighbors", self, "updateChunkNeighbors")
			chunks[x].append(chunk)
			add_child(chunk)
	
	for x in range(numChunksX - 1, -1, -1):
		for y in range(numChunksY - 1, -1, -1):
			chunks[x][y].generateChunk()
			if x > 0:
				chunks[x - 1][y].xNeighbor = chunks[x][y]
			if y > 0:
				chunks[x][y - 1].yNeighbor = chunks[x][y]
				if x > 0:
					chunks[x - 1][y - 1].xyNeighbor = chunks[x][y]

func updateChunkNeighbors(cX:int, cY:int):
	if cX >= 1:
		chunks[cX - 1][cY].updateChunk()
	if cY >= 1:
		chunks[cX][cY - 1].updateChunk()
		if cX >= 1:
			chunks[cX - 1][cY - 1].updateChunk()

func update_screen():
	# Setup screen size
	#OS.set_window_size(Vector2(screen_width, screen_height))
	#get_viewport().set_size_override(true, Vector2(columns * cellSize, rows * cellSize))
	
	for x in numChunksX:
		for y in numChunksY:
			if showDots:
				chunks[x][y].drawDots()
			else:
				chunks[x][y].hideDots()
			
			chunks[x][y].update()

# Updates values according to display choices
func setDisplayEditor(value:int):
	# Nothing
	if value == 0:
		showDots = false
		showGrid = false
	# Only Dots
	elif value == 1:
		showGrid = false
		showDots = true
	# Only Grid
	elif value == 2:
		showGrid = true
		showDots = false
	# Both
	else:
		showGrid = true
		showDots = true
	
	for c in chunks:
		c.showDots = showDots
		c.showGrid = showGrid

func setDisplay(value:int):
	# Nothing
	if value == 0:
		showDots = false
		showGrid = false
	# Only Dots
	elif value == 1:
		showGrid = false
		showDots = true
	# Only Grid
	elif value == 2:
		showGrid = true
		showDots = false
	# Both
	else:
		showGrid = true
		showDots = true
	
	for x in numChunksX:
		for y in numChunksY:
			chunks[x][y].showDots = showDots
			chunks[x][y].showGrid = showGrid
	
	update_screen()
