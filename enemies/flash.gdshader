shader_type canvas_item;

varying vec4 vertex_color; 

void vertex() {
	vertex_color = COLOR;
}

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	COLOR = vec4(vertex_color.r, vertex_color.g, vertex_color.b, t.a*vertex_color.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
