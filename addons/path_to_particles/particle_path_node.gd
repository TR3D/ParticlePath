@tool
class_name GPUParticlePathNode3D
extends GPUParticles3D

## Amount of particles emitted
@export var count = 16:
	set = set_count
		
## Particle speed
@export var speed = 1.0:
	set = set_speed

@onready var process_shader = load("res://addons/path_to_particles/particle_path_follow.gdshader")
@onready var process_mat = ShaderMaterial.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mat.shader = process_shader
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
	
	

# Set amount for inspector variable, particle system and process material
func set_count(value : int) -> void:
	count = value
	process_mat.set_shader_parameter("amount", value)
	amount = value
	
# Set speed for inspector variable and process material
func set_speed(value : float) -> void:
	speed = value
	process_mat.set_shader_parameter("speed", value)
