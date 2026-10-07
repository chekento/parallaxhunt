shader_type spatial;
render_mode diffuse_burley;
uniform vec4 stone_a : source_color = vec4(0.48,0.47,0.42,1.0);
uniform vec4 stone_b : source_color = vec4(0.56,0.54,0.47,1.0);
varying vec3 world_position;
void vertex() {
    world_position=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
}
void fragment() {
    vec2 p=world_position.xz/1.8;
    p.x+=mod(floor(p.y),2.0)*0.5;
    vec2 cell=floor(p);
    vec2 edge=min(fract(p),1.0-fract(p));
    float grout=smoothstep(0.012,0.035,min(edge.x,edge.y));
    float variation=fract(sin(dot(cell,vec2(127.1,311.7)))*43758.5453);
    vec3 stone=mix(stone_a.rgb,stone_b.rgb,variation);
    ALBEDO=mix(stone*0.57,stone,grout);
    ROUGHNESS=0.93;
}
