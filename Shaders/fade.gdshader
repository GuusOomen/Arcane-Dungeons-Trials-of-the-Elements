shader_type canvas_item;

uniform vec4 color: source_color = vec4(vec3(0.0), 1.0);

void fragment() {
	COLOR = vec4(color.rgb, UV.y * color.a);
}
