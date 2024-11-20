shader_type canvas_item;

uniform vec4 color_light  : source_color;
uniform vec4 color_medium : source_color;
uniform vec4 color_dark   : source_color;

void fragment() {
	const highp vec3 t1 = vec3(124.0 / 255.0, 25.0 / 255.0, 26.0 / 255.0);
	const highp vec3 t2 = vec3(170.0 / 255.0, 39.0 / 255.0, 44.0 / 255.0);
	const highp vec3 t3 = vec3(209.0 / 255.0, 64.0 / 255.0, 32.0 / 255.0);
	if (t1 == COLOR.rgb)
		t1;
}
