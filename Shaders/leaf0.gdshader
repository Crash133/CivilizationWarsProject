shader_type spatial;

render_mode depth_draw_always;

uniform vec4 albedo : source_color = vec4(1.0f);
uniform sampler2D albedo_texture : source_color;
uniform bool clamp_diffuse_to_max = false;

uniform float alpha_cutoff : hint_range(0.0, 1.0) = 0.3;
uniform vec2 size = vec2(2, 2);

uniform int cuts : hint_range(1, 8) = 3;
uniform float wrap : hint_range(-2.0f, 2.0f) = 0.0f;
uniform float steepness : hint_range(1.0f, 8.0f) = 1.0f;

uniform bool use_attenuation = true;
uniform bool use_ramp = false;
uniform sampler2D ramp : source_color;

uniform bool use_borders = false;
uniform float border_width = 0.01f;

varying vec3 vertex_pos;
varying vec3 normal;

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;

    vec3 to_camera = normalize(CAMERA_POSITION_WORLD - world_pos);
    to_camera.y = 0.0;
    to_camera = normalize(to_camera);

    vec3 up = vec3(0.0, 1.0, 0.0);
    vec3 right = normalize(cross(up, to_camera));
    up = normalize(cross(to_camera, right));

    vec3 local_pos = right * VERTEX.x * size.x + up * VERTEX.y * size.y;
    VERTEX = (inverse(MODEL_MATRIX) * vec4(world_pos + local_pos, 1.0)).xyz;
}

void fragment() {
	vec4 tex_color = texture(albedo_texture, UV);
	float brightness = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	if(brightness < alpha_cutoff){
		discard;
	}
	ALBEDO = albedo.rgb * tex_color.rgb;
	ALPHA = brightness;
}

void light() {
	// Attenuation.
	float attenuation = 1.0f;
	if (use_attenuation) {
		attenuation = ATTENUATION;
	}
	
	// Diffuse lighting.
	float NdotL = dot(NORMAL, LIGHT);
	float diffuse_amount = NdotL + (attenuation - 1.0) + wrap;
	diffuse_amount *= steepness;
	float cuts_inv = 1.0f / float(cuts);
	float diffuse_stepped = clamp(diffuse_amount + mod(1.0f - diffuse_amount, cuts_inv), 0.0f, 1.0f);

	float border = 0.0f;
	if (use_borders) {
		float corr_border_width = length(cross(NORMAL, LIGHT)) * border_width * steepness;
		border = step(diffuse_stepped - corr_border_width, diffuse_amount)
				 - step(1.0 - corr_border_width, diffuse_amount);
	}
	
	vec3 diffuse = ALBEDO.rgb * LIGHT_COLOR / PI;
	if (use_ramp) {
		diffuse *= texture(ramp, vec2(diffuse_stepped * (1.0f - border), 0.0f)).rgb;
	} else {
		diffuse *= diffuse_stepped * (1.0f - border);
	}
	
	if (clamp_diffuse_to_max) {
		DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, diffuse);
	} else {
		DIFFUSE_LIGHT += diffuse;
	}
}