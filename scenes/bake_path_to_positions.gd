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
@export_dir
var export_folder_path : String

## Texture file name override. Just uses name of the path3d node if left empty!
@export var texture_name_override := ""
	
## Bake the curve positions to a texture
@export_tool_button("Bake Path", "Bake")
var btn_bake = bake_positions

@export var tex_position : ImageTexture


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

var tex_image : Image
#endregion

signal bake_finished


func bake_positions() -> void:
	# Savety checks
	if path3d == null:
		printerr("Please assign a valid path3d node. Aborting!")
		return
		
	if export_folder_path.is_empty():
		printerr("Please provide a valid export folder path. Aborting!")
		return
	
	# Create resources
	tex_image = Image.create_empty(texture_width, 1, false, Image.FORMAT_RGBF)
	
	# Calculate data
	
	# Write data
	
	# Emit signal
	emit_signal("bake_finished")
	print("Baking texture!")
	
