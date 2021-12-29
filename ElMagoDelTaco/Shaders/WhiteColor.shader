shader_type canvas_item;

uniform bool active = true;

void fragment(){	
	vec4 previouse_color = texture(TEXTURE, UV);
	vec4 flash_color = vec4(1.0, 1.0, 1.0, previouse_color.a);
	vec4 new_color = previouse_color;
	if(active == true){
		new_color = flash_color;
	}
	COLOR = new_color;
}