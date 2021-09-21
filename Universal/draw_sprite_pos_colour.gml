#define draw_sprite_pos_colour
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
// NOTE: When using this function, you should have the No cropping setting enabled(GMS) or Automatically Crop setting disabled(GMS2) for texture pages, like draw_sprite_pos.
var sprite, subimg, x1, y1, x2, y2, x3, y3, x4, y4, c1, c2, c3, c4, alpha;
sprite = argument0;
subimg = argument1;
x1 = argument2;
y1 = argument3;
x2 = argument4;
y2 = argument5;
x3 = argument6;
y3 = argument7;
x4 = argument8;
y4 = argument9;
c1 = argument10;
c2 = argument11;
c3 = argument12;
c4 = argument13;
alpha = argument14;
// just draw_sprite_pos when colour is c_white
if ((c1 == c_white) && (c2 == c_white) && (c3 == c_white) && (c4 == c_white))
{
    draw_sprite_pos(sprite, subimg, x1, y1, x2, y2, x3, y3, x4, y4, alpha);
}
else if ((x1 == x4) && (x2 == x3) && (y1 == y2) && (y3 == y4)) // rectangle?
{
    if ((c1 == c2) && (c2 == c3) && (c3 == c4) && (c4 == c1)) // all colour value is same?
    {
        var a,c;
        a = draw_get_alpha(); // store current alpha
        c = draw_get_colour(); // store current colour
        draw_set_alpha(alpha); // alpha for drawn sprite
        draw_set_colour(c1); // colour for drawn sprite
        var srcx, srcy, srcw, srch, xsize, ysize;
        srcx = sprite_get_xoffset(sprite);
        srcy = sprite_get_yoffset(sprite);
        srcw = sprite_get_width(sprite);
        srch = sprite_get_height(sprite);
        xsize = (x2 - x1); // calculated xsize
        ysize = (y3 - y1); // calculated ysize
        if ((xsize == 0) || (ysize == 0))
        {
            draw_set_alpha(a); // restore previously stored alpha
            draw_set_colour(c); // restore previously stored colour
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
        draw_set_colour(c); // restore previously stored colour
    }
    else
    {
        var srcw, srch, xsize, ysize;
        srcw = sprite_get_width(sprite);
        srch = sprite_get_height(sprite);
        xsize = (x2 - x1); // calculated xsize
        ysize = (y3 - y1); // calculated ysize
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
    var texid;
    texid = sprite_get_texture(sprite, subimg); // sprite to draw
    draw_primitive_begin_texture(pr_trianglestrip, texid); // for GM8 compatiblity
    draw_vertex_texture_colour(x2,y2,1,0,c2,alpha); // top right
    draw_vertex_texture_colour(x3,y3,1,1,c3,alpha); // bottom right
    draw_vertex_texture_colour(x1,y1,0,0,c1,alpha); // top left
    draw_vertex_texture_colour(x4,y4,0,1,c4,alpha); // bottom left
    draw_primitive_end();
}

