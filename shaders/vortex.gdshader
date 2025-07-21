shader_type canvas_item;

// The texture that will be distorted and scrolled for the portal effect
uniform sampler2D portal_texture : source_color, filter_linear_mipmap_anisotropic;

// --- Effect Configuration ---

// General color tint for the portal
uniform vec4 portal_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Vortex Shape and Twist
// Defines the radius from the center where the vortex effects (like twist) are prominent.
uniform float vortex_effect_radius : hint_range(0.01, 1.0, 0.01) = 0.5;
// Strength of the twisting effect. Higher values mean more spiraling.
uniform float twist_strength : hint_range(0.0, 30.0, 0.1) = 8.0;

// Pulsation (Timing and Magnitude)
// Speed of the pulsation cycle. Affects how fast the portal twists and breathes.
uniform float pulsation_speed : hint_range(0.0, 5.0, 0.01) = 0.7;
// Magnitude of the shrink/expand "breathing" effect.
uniform float breath_magnitude : hint_range(-0.3, 0.3, 0.005) = 0.05;

// Overall Rotation
// Constant rotation speed for the entire portal.
uniform float overall_rotation_speed : hint_range(-2.0, 2.0, 0.01) = 0.25;

// Texture Scrolling
// Speed at which the portal_texture scrolls in the X direction.
uniform float texture_scroll_speed_x : hint_range(-1.0, 1.0, 0.01) = 0.08;
// Speed at which the portal_texture scrolls in the Y direction.
uniform float texture_scroll_speed_y : hint_range(-1.0, 1.0, 0.01) = 0.03;

// Appearance
// How soft the edge of the portal fades to transparency.
uniform float edge_softness : hint_range(0.01, 0.5, 0.005) = 0.1;


// --- Utility Functions ---

// Rotation matrix function
mat2 rotate(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat2(vec2(c, -s), vec2(s, c));
}

// --- Fragment Shader Logic ---

void fragment() {
    // --- 1. UV Preparation and Aspect Correction ---
    vec2 node_pixel_size = 1.0 / TEXTURE_PIXEL_SIZE;
    vec2 uv = UV - 0.5;

    if (node_pixel_size.x > node_pixel_size.y) {
        uv.x *= node_pixel_size.x / node_pixel_size.y;
    } else if (node_pixel_size.y > node_pixel_size.x) {
        uv.y *= node_pixel_size.y / node_pixel_size.x;
    }

    // --- 2. Time-based Progress for Pulsation ---
    float time_progress = sin(TIME * pulsation_speed);

    // --- 3. Overall Rotation ---
    if (overall_rotation_speed != 0.0) {
        uv = rotate(TIME * overall_rotation_speed) * uv;
    }

    // --- 4. Calculate Distance and Angle (Polar Coordinates) ---
    float distance_from_center = length(uv);

    // --- 5. Vortex/Twist Effect ---
    float twist_spatial_factor = smoothstep(0.0, vortex_effect_radius, vortex_effect_radius - distance_from_center);
    float current_animated_twist = twist_strength * time_progress;
    float twist_angle = twist_spatial_factor * current_animated_twist;

    if (distance_from_center < vortex_effect_radius) {
        uv = rotate(twist_angle) * uv;
    }

    // --- 6. Pulsating Shrink/Expand ("Breathing") Effect ---
    float breath_value = breath_magnitude * time_progress;
    if (distance_from_center > 0.0001) {
        float new_radial_distance = max(0.0, distance_from_center + breath_value);
        uv *= (new_radial_distance / distance_from_center);
    }

    // --- 7. Texture Scrolling ---
    // Combine the X and Y scroll speed uniforms into a vec2
    vec2 texture_scroll_speed = vec2(texture_scroll_speed_x, texture_scroll_speed_y);
    vec2 scroll_offset = TIME * texture_scroll_speed;
    vec2 final_scrolling_uv = uv + scroll_offset;

    // --- 8. Revert Aspect Correction and De-center for Texture Sampling ---
    if (node_pixel_size.x > node_pixel_size.y) {
        final_scrolling_uv.x /= (node_pixel_size.x / node_pixel_size.y);
    } else if (node_pixel_size.y > node_pixel_size.x) {
        final_scrolling_uv.y /= (node_pixel_size.y / node_pixel_size.x);
    }
    final_scrolling_uv += 0.5;

    // --- 9. Alpha Calculation for Portal Edge ---
    float alpha = smoothstep(vortex_effect_radius, vortex_effect_radius - edge_softness, distance_from_center);

    // --- 10. Texture Sampling and Final Color ---
    vec4 texture_color = texture(portal_texture, fract(final_scrolling_uv));

    COLOR = texture_color * portal_tint;
    COLOR.a *= alpha;

    if (UV.x < 0.0 || UV.x > 1.0 || UV.y < 0.0 || UV.y > 1.0) {
        COLOR.a = 0.0;
    }
}