shader_type canvas_item;

uniform vec2 offset;
uniform sampler2D NOISE_PATTERN;
uniform sampler2D NOISE_PATTERN_2;
uniform bool active = false;
uniform float alpha_filter : hint_range(0.0, 1.0);
uniform float brightness: hint_range(0.0, 2.0);
uniform float brightness_cutoff: hint_range(0.0, 2.0);
uniform float splashes : hint_range(0.0,0.3);
uniform float scale:hint_range(0.01, 4.0);
uniform vec2 wave_orientation = vec2(0.0,0.3);

uniform float waveSmoothing = .1;
uniform float mainWaveSpeed = 2.5;
uniform float mainWaveFrequency = 20;
uniform float mainWaveAmplitude = 0.005;

uniform vec4 shorelineColor : hint_color = vec4(1.);
uniform float shorelineSize : hint_range(0., 1.) = 0.0;

void fragment() {
	if (active){
		float t = (texture(NOISE_PATTERN, UV * 0.01 * scale + TIME * 0.001).x - 0.5 )* 0.02;
		float n = 	(1.0 - sin(3.14 + 	TIME * 0.5)) * (texture(NOISE_PATTERN, 		UV*scale*0.5 - TIME * t * wave_orientation * 0.1).x - 0.5)+
					(1.0 - sin(0.0 +	TIME * 0.5)) * (texture(NOISE_PATTERN_2, 	UV*scale*0.6 - TIME * t * wave_orientation * -0.1).x - 0.5);
		n = n * 0.5;
		float n2 = 	(1.0 - sin(3.14 + 	TIME * 0.2)) * (texture(NOISE_PATTERN_2, 	UV*scale*0.8 - TIME * t * wave_orientation * 0.2).x - 0.5)+
					(1.0 - sin(0.0 +	TIME * 0.2)) * (texture(NOISE_PATTERN, 		UV*scale*0.8 - TIME * t * wave_orientation * 0.1).x - 0.5);
		n2 = n2 * 0.5;
		vec4 sprite_texture = texture(TEXTURE, UV+(1.0 -abs(n))/8.0, 0.0);
		if ((alpha_filter <= sprite_texture.r || alpha_filter <= sprite_texture.b || alpha_filter <= sprite_texture.g) && sprite_texture.a == 1.0)
		{
			if (abs(n * 5.0)*(brightness*2.0) < brightness_cutoff){
				COLOR = clamp(sprite_texture * (1.1 + brightness - abs(n * 5.0) * (brightness*2.0)) * 0.8 ,0.0, 0.9);
			}
			else{
				COLOR = clamp(sprite_texture * (1.0 - abs(n * 0.5) * (brightness*2.0)) * 0.8 ,0.0, 0.7);
			}
			if (abs(n2) < splashes*0.5){
				COLOR = vec4(1.0,1.0,1.0,1.0);
			}
			if (abs(n) < splashes){
				COLOR = vec4(1.0,1.0,1.0,1.0);
			}
		}
		else
		{
			COLOR = vec4(0.,0.,0.,1.);
		}
		vec4 color = sprite_texture;
		float distFromTop = mainWaveAmplitude * (sin(UV.x * mainWaveFrequency + TIME * mainWaveSpeed) + sin(UV.x * mainWaveFrequency*3.1) * 0.5 ) + mainWaveAmplitude;
		float waveArea = UV.y - distFromTop;
		
		waveArea = smoothstep(0., 1. * waveSmoothing, waveArea);
		color.a *= waveArea;

		float shorelineBottom = UV.y - distFromTop - shorelineSize;
		shorelineBottom = smoothstep(0., 0.,  shorelineBottom);
		float shoreline = waveArea - shorelineBottom;
		color.rgb += shoreline * shorelineColor.rgb;
		//COLOR = vec4(abs(t*1.0))
		if (color.a == 0.0 || shoreline != 0.){
			COLOR = color;
		}
	}
	else
	{
		COLOR = texture(TEXTURE,UV);
	}
}