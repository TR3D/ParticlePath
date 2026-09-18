@tool
extends Node

@export var tex_pos : Image
@export var tex_up_vector : Image
@export var debug_mesh : Mesh

@export_tool_button("Spawn Meshes") var btn_spawn = spawn_meshes
@export_tool_button("Delete Meshes") var btn_delete = delete_meshes

var multi_mesh_instance : MultiMeshInstance3D

func spawn_meshes() -> void:
	if not Engine.is_editor_hint():
		printerr("Debugger is intended for editor use only!")
	
	var tex_image = tex_pos.get_data()
	var tex_up = tex_up_vector.get_data()
	
	# read data
	var pos : PackedVector3Array = tex_image.to_vector3_array()
	var up : PackedVector3Array = tex_up.to_vector3_array()
		
	# set up multi mesh
	multi_mesh_instance = MultiMeshInstance3D.new()
	multi_mesh_instance.name = "MultiMeshDebugger"
	var mm_data := MultiMesh.new()
	var instances = pos.size()
	
	mm_data.transform_format = MultiMesh.TRANSFORM_3D
	mm_data.mesh = debug_mesh
	mm_data.instance_count = instances
	
	# save previous position to calculate forward vector
	var prev_pos := pos[0]
	
	for i in range(instances):
		var position = pos[i]
		
		var up_vector = up[i]
		var forward_vector = (position - prev_pos).normalized()
		var right_vector = up_vector.cross(forward_vector).normalized()
		
		var transform = Transform3D.IDENTITY
		transform.origin = position
		transform.basis = Basis(right_vector, up_vector, forward_vector)
		mm_data.set_instance_transform(i, transform)
		
		# store prev_position for next iteration
		prev_pos = position
		
	# bind data to MultiMesh3D
	multi_mesh_instance.multimesh = mm_data
		
	
	var root_node = get_tree().edited_scene_root
	add_child(multi_mesh_instance)
	multi_mesh_instance.owner = root_node

func delete_meshes() -> void:
	multi_mesh_instance.queue_free()
