shader_type particles;

uniform sampler2D tex_position;
uniform sampler2D tex_up_vector;

uniform bool curve_closed = false;
uniform int amount = 8;
uniform float segment_size = 0.1;
uniform float speed = 2.0;


void start() {
	int samples = textureSize(tex_position, 0).x;
	
	// calculate uv_x coordinate
	float idx_normalized = float(INDEX) / float(max(amount , 1));
	int coord_x = int( round(idx_normalized * float(samples - 1)));
	ivec2 coords = ivec2(coord_x, 0);

	// read baked data using calulated coordinate
	vec3 pos = texelFetch(tex_position, coords, 0).rgb;
    
	// write data
	TRANSFORM[3].xyz = pos;
	
	// save data
	CUSTOM.r = float(samples); // samples
	CUSTOM.g = float(coord_x); // x coordinate in pixel
	
	// debug color
	//COLOR.rgb = vec3(float(INDEX) / float(amount));
	
}

void process() {
	// Called every frame on existing particles (according to the Fixed FPS property).
	int samples = int(CUSTOM.r);
	int uv_x_offset = int(CUSTOM.g);
	
	float dist = TIME * speed;
	float idx;
	float blend = modf(dist / segment_size, idx);
	
	// calculate uv_x for current and next index
	int uv0_x =  (int(idx) + uv_x_offset) % (samples - 1);
	int uv1_x = (uv0_x + 1) % (samples - 1);
	
	ivec2 uv0 = ivec2(uv0_x, 0);
	ivec2 uv1 = ivec2(uv1_x, 0);
		
	// hide particle while blending between end and start of curve
	if ( (!curve_closed) && (uv0_x == samples-2)) { ACTIVE = false; } //COLOR.a = 0.0; } 
	
	// sample current position and next position from texture
	vec3 pos0 = texelFetch(tex_position, uv0, 0).rgb;
	vec3 pos1 = texelFetch(tex_position, uv1, 0).rgb;
		
	// interpolate between positions for current position
	vec3 position = mix(pos0, pos1, blend);
	
	// calculate orientation 
	vec3 up_y0 = normalize( texelFetch(tex_up_vector, uv0, 0).rgb );
	vec3 up_y1 = normalize( texelFetch(tex_up_vector, uv1, 0).rgb );

	vec3 up_y = normalize( mix(up_y0, up_y1, blend) );
	vec3 up_z = normalize(position - TRANSFORM[3].xyz);
	vec3 up_x = cross(up_y, up_z);
	
	
	// write data
	TRANSFORM[0].xyz = up_x;
	TRANSFORM[1].xyz = up_y;
	TRANSFORM[2].xyz = up_z;
	TRANSFORM[3].xyz = position;
}
