#define get_rgb_shade
///get_rgb_shade(srcR,srcG,srcB,shadeR,shadeG,shadeB);
// get shaded (multiplied) color value
var sr,sg,sb,dr,dg,db;
sr = argument0 & $ff; // source red
sg = argument1 & $ff; // source green
sb = argument2 & $ff; // source blue
dr = argument3; // shade red
dg = argument4; // shade green
db = argument5; // shade blue
// calculate shade
return (max(0,min($ff, round(sr * dr))) << 16) | (max(0,min($ff, round(sg * dg))) << 8) | (max(0,min($ff, round(sb * db))) << 0);

#define get_rgb_shade_a
///get_rgb_shade_a(source,shadeR,shadeG,shadeB);
// source value is calculated RGB, see get_rgb_shade
var rgb;
rgb = argument0 & $ffffff;
return get_rgb_shade(rgb >> 16, rgb >> 8, rgb >> 0, argument1, argument2, argument3);

#define get_rgb_shade_b
///get_rgb_shade_b(srcR,srcG,srcB,shade);
// single shade value for overall color; see get_rgb_shade
return get_rgb_shade(argument0, argument1, argument2, argument3);

#define get_rgb_shade_c
///get_rgb_shade_c(source,shade);
// single shade value for overall color, source value is calculated RGB; see get_rgb_shade
return get_rgb_shade_a(argument0, argument1, argument1, argument1);

#define draw_sprite_ext_premultiplied
///draw_sprite_ext_premultiplied(sprite,subimg,x,y,xscale,yscale,rot,color,alpha);
// draw_sprite_ext with premultiplied alpha.
draw_set_blend_mode_ext(bm_one,bm_inv_src_alpha);
draw_sprite_ext(argument0,argument1,argument2,argument3,argument4,argument5,argument6,get_rgb_shade_c(argument7,argument8),argument8);
draw_set_blend_mode(bm_normal);

#define draw_self_premultiplied
///draw_self_premultiplied();
// draw_self with premultiplied alpha.
draw_sprite_ext_premultiplied(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,image_blend,image_alpha);

#define draw_sprite_general_premultiplied
///draw_sprite_general_premultiplied(sprite,subimg,left,top,width,height,x,y,xscale,yscale,rot,c1,c2,c3,c4,alpha);
// draw_sprite_general with premultiplied alpha.
draw_set_blend_mode_ext(bm_one,bm_inv_src_alpha);
draw_sprite_general(argument0,argument1,argument2,argument3,argument4,argument5,argument6,argument7,argument8,argument9,argument10,get_rgb_shade_c(argument11,argument15),get_rgb_shade_c(argument12,argument15),get_rgb_shade_c(argument13,argument15),get_rgb_shade_c(argument14,argument15),argument15);
draw_set_blend_mode(bm_normal);

#define draw_sprite_part_ext_premultiplied
///draw_sprite_part_ext_premultiplied(sprite,subimg,left,top,width,height,x,y,xscale,yscale,color,alpha);
// draw_sprite_part_ext with premultiplied alpha.
draw_set_blend_mode_ext(bm_one,bm_inv_src_alpha);
draw_sprite_part_ext(argument0,argument1,argument2,argument3,argument4,argument5,argument6,argument7,argument8,argument9,get_rgb_shade_c(argument10,argument11),argument11);
draw_set_blend_mode(bm_normal);

#define draw_sprite_stretched_ext_premultiplied
///draw_sprite_stretched_ext_premultiplied(sprite,subimg,x,y,w,h,color,alpha);
// draw_sprite_stretched_ext with premultiplied alpha.
draw_set_blend_mode_ext(bm_one,bm_inv_src_alpha);
draw_sprite_stretched_ext(argument0,argument1,argument2,argument3,argument4,argument5,get_rgb_shade_c(argument6,argument7),argument7);
draw_set_blend_mode(bm_normal);

#define draw_sprite_tiled_ext_premultiplied
///draw_sprite_tiled_ext_premultiplied(sprite,subimg,x,y,xscale,yscale,color,alpha);
// draw_sprite_tiled_ext with premultiplied alpha.
draw_set_blend_mode_ext(bm_one,bm_inv_src_alpha);
draw_sprite_tiled_ext(argument0,argument1,argument2,argument3,argument4,argument5,get_rgb_shade_c(argument6,argument7),argument7);
draw_set_blend_mode(bm_normal);

