#define draw_sprite_pos
/// draw_sprite_pos(sprite, subimg, x1, y1, x2, y2, x3, y3, x4, y4, alpha);
// Game Maker 8 implementation of draw_sprite_pos
// see draw_sprite_pos in GMS/2/.3 manual

var texid, a, c;
texid = sprite_get_texture(argument0, argument1); // sprite to draw
a = draw_get_alpha(); // store current alpha
c = draw_get_color(); // store current color
draw_set_alpha(argument10); // alpha for drawing sprite
draw_set_color(c_white); // c_white for draw this sprite correctly
draw_primitive_begin_texture(pr_trianglestrip, texid);
draw_vertex_texture(argument4,argument5,1,0); // top right
draw_vertex_texture(argument6,argument7,1,1); // bottom right
draw_vertex_texture(argument2,argument3,0,0); // top left
draw_vertex_texture(argument8,argument9,0,1); // bottom left
draw_primitive_end();
draw_set_alpha(a); // restore previously stored alpha
draw_set_color(c); // restore previously stored color

