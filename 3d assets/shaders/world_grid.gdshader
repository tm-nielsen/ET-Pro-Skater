shader_type spatial;
render_mode depth_draw_always;

uniform vec4 colour_a: source_color = vec4(1, 1, 1, 1);
uniform vec4 colour_b: source_color = vec4(0, 0, 0, 1);
uniform float grid_size = 10.0;

varying vec3 world_vertex;

void vertex() {
    world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec3 v = world_vertex / grid_size;
    float t = float(int(v.x) % 2);
    t = float(int(t + v.y) % 2);
    t = float(int(t + v.z) % 2);
    
    ALBEDO = colour_a.rgb * t + colour_b.rgb * (1.0 - t);
    ALPHA = colour_a.a * t + colour_b.a * (1.0 - t);
}
