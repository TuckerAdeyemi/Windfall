shader_type canvas_item;

uniform sampler2D noise_tex;
uniform float cutoff = 0.0;
uniform float edge_width = 0.05;
uniform vec4 edge_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float noise_val = texture(noise_tex, UV).r;

    // Discard pixels below cutoff (disintegrated)
    if (noise_val < cutoff) {
        discard;
    }

    // Optional: edge glow effect
    if (noise_val < cutoff + edge_width) {
        tex_color.rgb = mix(edge_color.rgb, tex_color.rgb, (noise_val - cutoff) / edge_width);
    }

    COLOR = tex_color;
}
