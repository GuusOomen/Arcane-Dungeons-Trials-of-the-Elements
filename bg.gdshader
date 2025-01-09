shader_type canvas_item;

uniform sampler2D noise1 : repeat_enable;
uniform sampler2D noise2 : repeat_enable;
uniform sampler2D noise3 : repeat_enable;

void fragment() {
	float mask = 0.0;
	mask = mix(mask, texture(noise1, 2.0 * (SCREEN_UV + TIME * vec2(0.0, 0.1))).r, 0.1);
	mask = mix(mask, texture(noise2, 1.0 * (SCREEN_UV + TIME * vec2(0.1, 0.0))).r, 0.2);
	mask = mix(mask, texture(noise3, 0.5 * (SCREEN_UV + TIME * vec2(-0.1, 0.1))).r, 0.3);
	mask *= smoothstep(-9.0, 10.0, 0.5 * (1.0 + sin(2.0 * TIME)));
	COLOR.rgb *= vec3(mask);
}
