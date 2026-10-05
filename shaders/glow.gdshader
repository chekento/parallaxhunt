shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.45, 0.95, 0.82, 1.0);
uniform float strength : hint_range(0.0, 2.0) = 0.55;

void fragment() {
    vec4 c = texture(TEXTURE, UV);
    float edge = smoothstep(0.0, 0.8, c.a);
    COLOR = vec4(mix(c.rgb, glow_color.rgb, strength * edge), c.a);
}
