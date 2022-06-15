shader_type canvas_item;

uniform sampler2D DirtTexture;
uniform vec4 Dirt : hint_color = vec4(1.);

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	if (COLOR == Dirt){
		COLOR = texture(DirtTexture, UV)
	}

}