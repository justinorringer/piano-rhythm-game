shader_type spatial;
render_mode unshaded, cull_front, blend_mix;

uniform float grow_amount = 0.05;
uniform vec4 outline_color = vec4(0.0, 0.0, 0.0, 1.0);

void vertex() {
    float scale_x = length(MODEL_MATRIX[0].xyz);
    float scale_y = length(MODEL_MATRIX[1].xyz);
    float scale_z = length(MODEL_MATRIX[2].xyz);

    vec3 normalized_vertex = VERTEX / vec3(scale_x, scale_y, scale_z);

    VERTEX += normalized_vertex * grow_amount;
}

void fragment() {
    ALBEDO = outline_color.rgb;
    ALPHA = outline_color.a;
}