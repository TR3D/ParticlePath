@tool
extends Node

#region variables
## Path which is used for sampling
@export var path3d : Path3D

## Width of output texture
@export_enum("16:16", "32:32", "64:64", "128:128", "256:256", "512:512" , "1024:1024") 
var texture_width := 32

## Spacing between position samples in world space (read only)
@export_placeholder("Sample gaps") 
var gap_size_ : 
	get() : return str(spacing).pad_decimals(3)	

## Save texture output to this folder
@export_dir var export_folder_path : String

## Texture file name override. Just uses name of the path3d node if left empty!
@export var texture_name_override := ""
	
## Bake the curve positions to a texture
@export_tool_button("Bake Path", "Bake")
var btn_bake = bake_positions

## Baked position texture
@export var tex_position : CompressedTexture2D

## Baked up vector texture
@export var tex_up_vector : CompressedTexture2D


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
		
	# assign baked textures 
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()
		tex_position = load(path_pos + "_pos.tres") as CompressedTexture2D
		tex_up_vector = load(path_up+ "_up.tres") as CompressedTexture2D
	
	# Emit signal
	emit_signal("bake_finished")
	print("Done baking!")
	
