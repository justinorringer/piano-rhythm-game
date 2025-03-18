shader_type spatial;
render_mode unshaded, cull_front, blend_mix, depth_draw_always;
uniform float grow_amount = 0.05;
uniform vec4 outline_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float depth_offset = 0.0001;

void vertex() {
    float scale_x = length(MODEL_MATRIX[0].xyz);
    float scale_y = length(MODEL_MATRIX[1].xyz);
    float scale_z = length(MODEL_MATRIX[2].xyz);
    vec3 normalized_vertex = VERTEX / vec3(scale_x, scale_y, scale_z);
    VERTEX += normalized_vertex * grow_amount;
    
    // Apply a small depth offset to avoid z-fighting
    VERTEX -= NORMAL * depth_offset;
}

void fragment() {
    ALBEDO = outline_color.rgb;
    ALPHA = outline_color.a;
    
    // Ensure outline is drawn correctly by adjusting depth
    DEPTH = FRAGCOORD.z - 0.0001;
}