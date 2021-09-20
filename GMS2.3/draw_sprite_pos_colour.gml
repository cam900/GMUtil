/// draw_sprite_pos_colour(sprite, subimg, x1, y1, x2, y2, x3, y3, x4, y4, c1, c2, c3, c4, alpha);
// draw_sprite_pos with colour blending
// Argument : Description
// sprite : Sprite index to draw
// subimg : Subimage index of the drawn sprite
// x* : the x coordinate of the drawn sprite
// y* : the y coordinate of the drawn sprite
// c* : The colour blend of the drawn sprite
// *1 : Top left
// *2 : Top right
// *3 : Bottom right
// *4 : Bottom left
// NOTE: When using this function, you should have the Automatically Crop setting disabled for texture pages, like draw_sprite_pos.

function draw_sprite_pos_colour(sprite, subimg, x1, y1, x2, y2, x3, y3, x4, y4, c1, c2, c3, c4, alpha)
{
	// just draw_sprite_pos when colour is c_white
	if ((c1 == c_white) && (c2 == c_white) && (c3 == c_white) && (c4 == c_white))
	{
		draw_sprite_pos(sprite, subimg, x1, y1, x2, y2, x3, y3, x4, y4, alpha);
	}
	var texid = sprite_get_texture(sprite, subimg); // sprite to draw
	draw_primitive_begin_texture(pr_trianglestrip, texid); // for GM8 compatiblity
	draw_vertex_texture_colour(x2,y2,1,0,c2,alpha); // top right
	draw_vertex_texture_colour(x3,y3,1,1,c3,alpha); // bottom right
	draw_vertex_texture_colour(x1,y1,0,0,c1,alpha); // top left
	draw_vertex_texture_colour(x4,y4,0,1,c4,alpha); // bottom left
	draw_primitive_end();
}