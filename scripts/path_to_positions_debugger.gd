@tool
extends Node

@export var tex_pos : CompressedTexture2D
@export var tex_up_vector : CompressedTexture2D
@export var debug_mesh : Mesh

@export_tool_button("Spawn Meshes") var btn_spawn = spawn_meshes


func spawn_meshes() -> void:
	if not Engine.is_editor_hint():
		printerr("Debugger is intended for editor use only!")
	
	var tex_image = tex_pos.get_image()
	var tex_up = tex_up_vector.get_image()

	if tex_image.is_compressed():
		tex_image.decompress()
		
	if tex_up.is_compressed():
		tex_up.decompress()
	
	# read data
	var pos : PackedVector3Array = tex_image.get_data().to_vector3_array()
	var up : PackedVector3Array = tex_up.get_data().to_vector3_array()
		
	# set up multi mesh
	var multi_mesh_instance := MultiMeshInstance3D.new()
	multi_mesh_instance.name = "MultiMeshDebugger"
	var mm_data := MultiMesh.new()
	var instances = pos.size()
	
	mm_data.transform_format = MultiMesh.TRANSFORM_3D
	mm_data.mesh = debug_mesh
	mm_data.instance_count = instances
	
	# save previous position to calculate forward vector
	var prev_pos := Vector3.ZERO
	
	for i in range(instances):
		var position = pos[i]
		
		var up_vector = up[i]
		var forward_vector = (position - prev_pos).normalized()
		var right_vector = up_vector.cross(forward_vector)
		
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
