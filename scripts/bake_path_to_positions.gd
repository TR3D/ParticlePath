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
			return path3d.curve.get_baked_length() / texture_width
		else: 
			return 0.0

# Internal texture name, use path3d name if the user didn't provide something else
var texture_name : String:
	get() :
		if texture_name_override.is_empty():
			return path3d.name.to_snake_case()
		return texture_name_override

#endregion

signal bake_finished

# helper function
func save_texture(path: String, data: Image) -> void:
	var error = data.save_png(path)
	if error != OK:
		print("error saving %s" % path)
	
func bake_positions() -> void:
	# Safety checks
	if path3d == null:
		printerr("Please assign a valid path3d node. Aborting!")
		return
		
	if export_folder_path.is_empty():
		printerr("Please provide a valid export folder path. Aborting!")
		return
	
	print("Baking texture!")
	
	# Create resources
	var curve_positions : PackedVector3Array
	var curve_up : PackedVector3Array
	
	# Calculate data
	for i in range(texture_width):
		var distance = i * spacing
		var sample_trans = path3d.curve.sample_baked_with_rotation(distance, true, false)
		
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
		
	var path_pos:= export_folder_path.path_join(path3d.name + "_pos.png")
	save_texture(path_pos, pos_image)
	
	var path_up:= export_folder_path.path_join(path3d.name + "_up.png")
	save_texture(path_up, up_image)
	
	# assign baked textures 
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()
		tex_position = load(path_pos)
		tex_up_vector = load(path_up)
	
	# Emit signal
	emit_signal("bake_finished")
	print("Done baking!")
	
