shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

vec3 saturate(vec3 color, float amount)
{
	return mix(vec3(dot(color, vec3(0.299, 0.587, 0.114))), color, amount);
}

vec3 reinhard_jodie(vec3 color)
{
    vec3 tmp = color / (1.0 + color);
    return mix(color / (1.0 + dot(color, vec3(0.299, 0.587, 0.114))), tmp, tmp);
}

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR.rgb *= 1.8;
	COLOR.rgb = saturate(COLOR.rgb, 0.9);
	COLOR.rgb = reinhard_jodie(COLOR.rgb);
}
