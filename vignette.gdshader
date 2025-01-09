shader_type canvas_item;
render_mode blend_mix;

void fragment() {
	COLOR.a = smoothstep(0.0, 1.0, distance(vec2(0.5), SCREEN_UV));
}
