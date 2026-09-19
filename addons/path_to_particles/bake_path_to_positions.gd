@tool
class_name PathBakerNode3D
extends Path3D

#region variables
## Path which is used for sampling
@export var path3d : Path3D = self

## Width of output texture
@export_enum("16:16", "32:32", "64:64", "128:128", "256:256", "512:512" , "1024:1024") 
var texture_width := 32

## Spacing between position samples in world space (read only)
@export_placeholder("Sample gaps") 
var gap_size_ : 
	get() : return str(spacing).pad_decimals(3)

## Save texture output to this folder
@export_dir var export_folder_path : String = "res://"

## Texture file name override. Just uses name of the path3d node if left empty!
@export var texture_name_override := ""
	
## Bake the curve positions to a texture
@export_tool_button("Bake Path", "Bake")
var btn_bake = bake_positions

## Baked position texture
@export var tex_position : Image

## Baked up vector texture
@export var tex_up_vector : Image

@export_category("Debug")
@export_tool_button("Spawn Debugger")
var btn_spawn_debug = spawn_debugger

@export_tool_button("Delete Debugger")
var btn_remove_debugger = remove_debugger

# Internal spacing variable for calculations
var spacing : 
	get() :
		if path3d != null: 
			return path3d.curve.get_baked_length() / max(texture_width-1, 1) # sample at exact end of curve
		else: 
			return 0.0

# Internal texture name, use path3d name if left empty by user
var texture_name : String:
	get() :
		if texture_name_override.is_empty():
			return path3d.name.to_snake_case()
		return texture_name_override
#endregion

signal bake_finished

# helper function
func save_texture(path: String, suffix : String, data: Image) -> void:
	var error = data.save_exr(path + suffix + ".exr")
	if error != OK:
		print("error saving %s" % path)
		
func save_resource(path: String, suffix : String, data: Resource) -> void:
	var complete_path = path + suffix + ".tres"
	var error = ResourceSaver.save(data, complete_path)  #ave_exr(path + suffix + ".exr")
	if error != OK:
		push_error("Failed to save %s (error %d)" % [complete_path, error])
	else:
		print("Saved data to ", complete_path)

func bake_positions() -> void:
	if path3d == null:
		printerr("Please assign a valid path3d node. Aborting!")
		return
		
	if export_folder_path.is_empty():
		printerr("Please provide a valid export folder path. Aborting!")
		return
	
	print("Baking textures!")
	
	# Create resources
	var curve_positions : PackedVector3Array
	var curve_up : PackedVector3Array
	var length = path3d.curve.get_baked_length()
	
	# Calculate data
	for i in range(texture_width):
		# clamp distance to exact curve length
		var distance = min(i * spacing, length)
		# sample path in world space
		var sample_trans = path3d.global_transform * path3d.curve.sample_baked_with_rotation(distance, true)
		
		curve_positions.append(sample_trans.origin)
		curve_up.append(sample_trans.basis.y)
	
	# Write data
	var pos_image := Image.create_from_data(
		texture_width, 1,
		false,
		Image.FORMAT_RGBF,
		curve_positions.to_byte_array())
	
	var up_image := Image.create_from_data(
		texture_width, 1,
		false,
		Image.FORMAT_RGBF,
		curve_up.to_byte_array())
		
	var path_pos:= export_folder_path.path_join(texture_name)
	save_resource(path_pos, "_pos", pos_image)
	
	var path_up:= export_folder_path.path_join(texture_name)
	save_resource(path_up, "_up", up_image)
		
	# assign baked textures to inspector
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()
		
		var pos_path := path_pos + "_pos.tres"
		var up_path := path_up + "_up.tres"
		
		var tex_pos = ResourceLoader.load(pos_path, "", ResourceLoader.CACHE_MODE_IGNORE)
		var tex_up = ResourceLoader.load(up_path, "", ResourceLoader.CACHE_MODE_IGNORE)

		set("tex_position", tex_pos)
		set("tex_up_vector", tex_up)
		notify_property_list_changed()
	
	# Emit signal
	emit_signal("bake_finished")
	print("Done baking!")

func spawn_debugger() -> void:
	var debugger = PathBakerDebuggerNode3D.new()
	debugger.tex_pos = tex_position
	debugger.tex_up_vector = tex_up_vector
	debugger.name = "PathBakerDebuggerNode3D"
	add_child(debugger, true)
	
	if Engine.is_editor_hint():
		debugger.owner = get_tree().edited_scene_root
	
	debugger.spawn_meshes()
	
func remove_debugger() -> void:
	if get_child_count() > 0:
		var debugger = get_child(0)
		if debugger:
			debugger.queue_free()
	else: 
		printerr("No debugger child node found. Aborting!")
