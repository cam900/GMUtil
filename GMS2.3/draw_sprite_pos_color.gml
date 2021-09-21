/// draw_sprite_pos_color(sprite, subimg, x1, y1, x2, y2, x3, y3, x4, y4, c1, c2, c3, c4, alpha);
// draw_sprite_pos with color blending
// Argument : Description
// sprite : Sprite index to draw
// subimg : Subimage index of the drawn sprite
// x* : the x coordinate of the drawn sprite
// y* : the y coordinate of the drawn sprite
// c* : The color blend of the drawn sprite
// *1 : Top left
// *2 : Top right
// *3 : Bottom right
// *4 : Bottom left
// NOTE: When using this function, you should have the Automatically Crop setting disabled for texture pages, like draw_sprite_pos.

function draw_sprite_pos_color(sprite, subimg, x1, y1, x2, y2, x3, y3, x4, y4, c1, c2, c3, c4, alpha)
{
	// just draw_sprite_pos when color is c_white
	if ((c1 == c_white) && (c2 == c_white) && (c3 == c_white) && (c4 == c_white))
	{
		draw_sprite_pos(sprite, subimg, x1, y1, x2, y2, x3, y3, x4, y4, alpha);
	}
	else if ((x1 == x4) && (x2 == x3) && (y1 == y2) && (y3 == y4)) // rectangle?
	{
		if ((c1 == c2) && (c2 == c3) && (c3 == c4) && (c4 == c1)) // all color value is same?
		{
			var a = draw_get_alpha(); // store current alpha
			var c = draw_get_color(); // store current color
			draw_set_alpha(alpha); // alpha for drawn sprite
			draw_set_color(c1); // color for drawn sprite
			var srcx = sprite_get_xoffset(sprite);
			var srcy = sprite_get_yoffset(sprite);
			var srcw = sprite_get_width(sprite);
			var srch = sprite_get_height(sprite);
			var xsize = (x2 - x1); // calculated xsize
			var ysize = (y3 - y1); // calculated ysize
			if ((xsize == 0) || (ysize == 0))
			{
				draw_set_alpha(a); // restore previously stored alpha
				draw_set_color(c); // restore previously stored color
				return false;
			}
			else if ((xsize == sprite_get_width(sprite)) && (ysize == sprite_get_height(sprite))) // if size is same as source
			{
				draw_sprite(sprite,subimg,x1+srcx,y1+srcy);
			}
			else if ((xsize > 0) && (ysize > 0))
			{
				draw_sprite_stretched(sprite,subimg,x1,y1,x2-x1,y3-y1);
			}
			else
			{
				xsize /= srcw;
				ysize /= srch;
				draw_sprite_ext(sprite,subimg,x1+(srcx*xsize),y1+(srcy*ysize),xsize,ysize,0,c1,alpha);
			}
			draw_set_alpha(a); // restore previously stored alpha
			draw_set_color(c); // restore previously stored color
		}
		else
		{
			var srcw = sprite_get_width(sprite);
			var srch = sprite_get_height(sprite);
			var xsize = (x2 - x1); // calculated xsize
			var ysize = (y3 - y1); // calculated ysize
			if ((xsize == 0) || (ysize == 0))
			{
				return false;
			}
			else if ((xsize == sprite_get_width(sprite)) && (ysize == sprite_get_height(sprite))) // if size is same as source
			{
				draw_sprite_general(sprite,subimg,0,0,sprite_get_width(sprite),sprite_get_height(sprite),x1,y1,1,1,0,c1,c2,c3,c4,alpha);
			}
			else
			{
				xsize /= srcw;
				ysize /= srch;
				draw_sprite_general(sprite,subimg,0,0,sprite_get_width(sprite),sprite_get_height(sprite),x1,y1,xsize,ysize,0,c1,c2,c3,c4,alpha);
			}
		}
	}
	else
	{
		var texid = sprite_get_texture(sprite, subimg); // sprite to draw
		draw_primitive_begin_texture(pr_trianglestrip, texid); // for GM8 compatiblity
		draw_vertex_texture_color(x2,y2,1,0,c2,alpha); // top right
		draw_vertex_texture_color(x3,y3,1,1,c3,alpha); // bottom right
		draw_vertex_texture_color(x1,y1,0,0,c1,alpha); // top left
		draw_vertex_texture_color(x4,y4,0,1,c4,alpha); // bottom left
		draw_primitive_end();
	}
}