@tool
class_name GPUParticlePathNode3D
extends GPUParticles3D

## Amount of particles emitted
@export var count = 16:
	set = set_count
		
## Particle speed
@export var speed = 1.0:
	set = set_speed

@export var process_mat : ShaderMaterial

var process_shader = preload("res://addons/path_to_particles/particle_path_follow.gdshader")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if process_mat == null:
		process_mat = ShaderMaterial.new()
		process_mat.shader = process_shader
		process_mat.resource_local_to_scene = true
		
	set_process_material(process_mat)
	
	# Create material
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	
	# Create mesh
	var particle_mesh = QuadMesh.new()
	particle_mesh.size = Vector2(0.1, 0.1)
	particle_mesh.orientation = PlaneMesh.FACE_Y
	particle_mesh.material = mat
	
	# Assign mesh to draw pass
	draw_pass_1 = particle_mesh
	
	# Make particle calculations in local space
	local_coords = true
	
	# Apply the current exported values
	amount = count
	process_mat. set_shader_parameter("amount", count)
	process_mat.set_shader_parameter("speed", speed)
	
	# Make sure particles are actually running
	emitting = true
	restart()
	

# Set amount for inspector variable, particle system and process material
func set_count(value : int) -> void:
	count = value
	amount = value
	if process_mat:
			process_mat.set_shader_parameter("amount", value)
		
	
# Set speed for inspector variable and process material
func set_speed(value : float) -> void:
	speed = value
	if process_mat:
		process_mat.set_shader_parameter("speed", value)
