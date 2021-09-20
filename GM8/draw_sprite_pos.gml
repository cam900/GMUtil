#define draw_sprite_pos
/// draw_sprite_pos(sprite, subimg, x1, y1, x2, y2, x3, y3, x4, y4, alpha);
// Game Maker 8 implementation of draw_sprite_pos
// see draw_sprite_pos in GMS/2/.3 manual

var sprite, subimg, x1, y1, x2, y2, x3, y3, x4, y4, alpha;
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
alpha = argument10;
// vaild?
if ((!sprite_exists(sprite)) || (alpha == 0) || (sprite_get_width(sprite) <= 0) || (sprite_get_height(sprite) <= 0))
{
    return false;
}
var a,c;
a = draw_get_alpha(); // store current alpha
c = draw_get_color(); // store current color
draw_set_alpha(alpha); // alpha for drawing sprite
draw_set_color(c_white); // c_white for draw this sprite correctly
if ((x1 == x4) && (x2 == x3) && (y1 == y2) && (y3 == y4)) // rectangle?
{
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
        draw_sprite_ext(sprite,subimg,x1+(srcx*xsize),y1+(srcy*ysize),xsize,ysize,0,c_white,alpha);
    }
}
else
{
    // draw texture with "shearing" like GMS draw_sprite_pos function
    var texid;
    texid = sprite_get_texture(sprite, subimg); // sprite to draw
    draw_primitive_begin_texture(pr_trianglestrip, texid);
    draw_vertex_texture(x2,y2,1,0); // top right
    draw_vertex_texture(x3,y3,1,1); // bottom right
    draw_vertex_texture(x1,y1,0,0); // top left
    draw_vertex_texture(x4,y4,0,1); // bottom left
    draw_primitive_end();
}
draw_set_alpha(a); // restore previously stored alpha
draw_set_color(c); // restore previously stored color
return true;

