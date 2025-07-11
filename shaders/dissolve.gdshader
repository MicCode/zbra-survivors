shader_type canvas_item;
uniform float progress = 0.0;
uniform float noiseForce = 0.2;
uniform sampler2D noiseTexture;
uniform vec4 burnColor: source_color;
uniform float borderWidth;
uniform float direction = 180.0f;

vec2 degreesToPerpendicular(){
	return vec2(cos(radians((direction))), -sin(radians(direction)));
}
void fragment(){
	vec2 normUV = UV * 2.0 - 1.0;
	COLOR.rgb = mix(COLOR.rgb, burnColor.rgb, float(dot(normUV, degreesToPerpendicular()) + (texture(noiseTexture, UV).r * noiseForce) < (progress + borderWidth)));
	if(!(dot(normUV, degreesToPerpendicular()) + (texture(noiseTexture, UV).r * noiseForce) > progress)){
		COLOR.a = 0.0;
	}
}