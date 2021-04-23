extends Node2D

class_name Voxel

var state:int
var xEdge:Vector2
var yEdge:Vector2

func _init(pos:Vector2, size:float):
	position.x = (pos.x + 0.5)
	position.y = (pos.y + 0.5)
	
	xEdge = position
	xEdge.x += size * 0.5
	yEdge = position
	yEdge.y += size * 0.5

func duplicateVoxelX(voxel:Voxel, offset:float):
	state = voxel.state
	position = voxel.position
	xEdge = voxel.xEdge
	yEdge = voxel.yEdge
	position.x += offset
	xEdge.x += offset
	yEdge.x += offset

func duplicateVoxelY(voxel:Voxel, offset:float):
	state = voxel.state
	position = voxel.position
	xEdge = voxel.xEdge
	yEdge = voxel.yEdge
	position.y += offset
	xEdge.y += offset
	yEdge.y += offset

func duplicateVoxelXY(voxel:Voxel, offset:float):
	state = voxel.state
	position = voxel.position
	xEdge = voxel.xEdge
	yEdge = voxel.yEdge
	position.x += offset
	position.y += offset
	xEdge.x += offset
	xEdge.y += offset
	yEdge.x += offset
	yEdge.y += offset
