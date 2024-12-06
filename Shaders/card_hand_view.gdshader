shader_type canvas_item;

uniform bool active = false; // Declare a boolean uniform variable
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (active) {
		COLOR = texture(TEXTURE, UV);
		float lumi = COLOR.r * 0.2126 + COLOR.g * 0.7152 + COLOR.b * 0.0722;
		COLOR.rgb = vec3(lumi);
		// Called for every pixel the material is visible on.
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
