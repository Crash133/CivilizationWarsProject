shader_type spatial;

render_mode cull_disabled; 

uniform sampler2D texture_albedo : source_color;
uniform float texture_scale = 0.5;
uniform vec4 tint_color : source_color = vec4(1.0, 0.7, 0.4, 1.0);
uniform float light_intensity = 1.0;
uniform float light_smoothness = 1.5;

varying vec3 v_world_pos;
varying vec3 v_world_normal;

void vertex() {
    v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    v_world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
    vec3 wp = v_world_pos * texture_scale;
    vec3 n = abs(v_world_normal);

    vec2 uv_x = wp.yz;
    vec2 uv_y = wp.xz;
    vec2 uv_z = wp.xy;

    vec4 tx = texture(texture_albedo, uv_x);
    vec4 ty = texture(texture_albedo, uv_y);
    vec4 tz = texture(texture_albedo, uv_z);

    vec3 blend = max(n, vec3(0.0001));
    blend /= (blend.x + blend.y + blend.z);

    vec3 base_color = tx.rgb * blend.x + ty.rgb * blend.y + tz.rgb * blend.z;
    base_color *= tint_color.rgb;

    vec3 light_dir = normalize(vec3(0.5, 1.0, 0.3));
    float light_amount = max(dot(normalize(v_world_normal), light_dir), 0.0);
    light_amount = pow(light_amount, light_smoothness) * light_intensity;
   
    base_color *= mix(0.5, 1.2, light_amount);
    ALBEDO = base_color;
}