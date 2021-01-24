function get_rgb_shade(){
	///get_rgb_shade(srcR,srcG,srcB,shadeR,shadeG,shadeB);
	///get_rgb_shade(srcRGB,shadeR,shadeG,shadeB);
	///get_rgb_shade(srcRGB,shade);
	// get shaded (multiplied) color value
	if (argument_count == 6)
	{
		var sr = argument[0] & $ff; // source red
		var sg = argument[1] & $ff; // source green
		var sb = argument[2] & $ff; // source blue
		var dr = argument[3]; // shade red
		var dg = argument[4]; // shade green
		var db = argument[5]; // shade blue
		// calculate shade
		return (max(0,min($ff, round(sr * dr))) << 16) | (max(0,min($ff, round(sg * dg))) << 8) | (max(0,min($ff, round(sb * db))) << 0);
	}
	else if (argument_count == 4)
	{
		return get_rgb_shade(argument[0] >> 16, argument[0] >> 8, argument[0] >> 0, argument[1], argument[2], argument[3]);
	}
	else if (argument_count == 2)
	{
		return get_rgb_shade(argument[0], argument[1], argument[1], argument[1]);
	}
}

function get_rgb_shade_a(){
	///get_rgb_shade_a(srcR,srcG,srcB,shadeR,shadeG,shadeB);
	///get_rgb_shade_a(srcR,srcG,srcB,shade);
	///get_rgb_shade_a(srcRGB,shade);
	// same as get_rgb_shade, but different format
	if (argument_count == 6)
	{
	    return get_rgb_shade(argument[0], argument[1], argument[3], argument[3], argument[4], argument[5]);
	}
	else if (argument_count == 4)
	{
	    return get_rgb_shade(argument[0], argument[1], argument[3], argument[3], argument[3], argument[3]);
	}
	else if (argument_count == 2)
	{
	    return get_rgb_shade(argument[0], argument[1], argument[1], argument[1]);
	}
}

function draw_sprite_ext_premultiplied(_sprite,_subimg,_x,_y,_xscale,_yscale,_rot,_color,_alpha){
	///draw_sprite_ext_premultiplied(sprite,subimg,x,y,xscale,yscale,rot,color,alpha);
	// draw_sprite_ext with premultiplied alpha.
	gpu_push_state();
	gpu_set_blendmode_ext_sepalpha(bm_one,bm_inv_src_alpha,bm_src_alpha,bm_inv_src_alpha);
	draw_sprite_ext(_sprite,_subimg,_x,_y,_xscale,_yscale,_rot,get_rgb_shade(_color,_alpha),_alpha);
	gpu_pop_state();
}

function draw_self_premultiplied(){
	///draw_self_premultiplied();
	// draw_self with premultiplied alpha.
	draw_sprite_ext_premultiplied(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,image_blend,image_alpha);
}

function draw_sprite_general_premultiplied(_sprite,_subimg,_left,_top,_width,_height,_x,_y,_xscale,_yscale,_rot,_c1,_c2,_c3,_c4,_alpha){
	///draw_sprite_general_premultiplied(sprite,subimg,left,top,width,height,x,y,xscale,yscale,rot,c1,c2,c3,c4,alpha);
	// draw_sprite_general with premultiplied alpha.
	gpu_push_state();
	gpu_set_blendmode_ext_sepalpha(bm_one,bm_inv_src_alpha,bm_src_alpha,bm_inv_src_alpha);
	draw_sprite_general(_sprite,_subimg,_left,_top,_width,_height,_x,_y,_xscale,_yscale,_rot,get_rgb_shade(_c1,_alpha),get_rgb_shade(_c2,_alpha),get_rgb_shade(_c3,_alpha),get_rgb_shade(_c4,_alpha),_alpha);
	gpu_pop_state();
}

function draw_sprite_part_ext_premultiplied(_sprite,_subimg,_left,_top,_width,_height,_x,_y,_xscale,_yscale,_color,_alpha){
	///draw_sprite_part_ext_premultiplied(sprite,subimg,left,top,width,height,x,y,xscale,yscale,color,alpha);
	// draw_sprite_part_ext with premultiplied alpha.
	gpu_push_state();
	gpu_set_blendmode_ext_sepalpha(bm_one,bm_inv_src_alpha,bm_src_alpha,bm_inv_src_alpha);
	draw_sprite_part_ext(_sprite,_subimg,_left,_top,_width,_height,_x,_y,_xscale,_yscale,get_rgb_shade(_color,_alpha),_alpha);
	gpu_pop_state();
}

function draw_sprite_stretched_ext_premultiplied(_sprite,_subimg,_x,_y,_w,_h,_color,_alpha){
	///draw_sprite_stretched_ext_premultiplied(sprite,subimg,x,y,w,h,color,alpha);
	// draw_sprite_stretched_ext with premultiplied alpha.
	gpu_push_state();
	gpu_set_blendmode_ext_sepalpha(bm_one,bm_inv_src_alpha,bm_src_alpha,bm_inv_src_alpha);
	draw_sprite_stretched_ext(_sprite,_subimg,_x,_y,_w,_h,get_rgb_shade(_color,_alpha),_alpha);
	gpu_pop_state();
}

function draw_sprite_tiled_ext_premultiplied(_sprite,_subimg,_x,_y,_xscale,_yscale,_color,_alpha){
	///draw_sprite_tiled_ext_premultiplied(sprite,subimg,x,y,xscale,yscale,color,alpha);
	// draw_sprite_tiled_ext with premultiplied alpha.
	gpu_push_state();
	gpu_set_blendmode_ext_sepalpha(bm_one,bm_inv_src_alpha,bm_src_alpha,bm_inv_src_alpha);
	draw_sprite_tiled_ext(_sprite,_subimg,_x,_y,_xscale,_yscale,get_rgb_shade(_color,_alpha),_alpha);
	gpu_pop_state();
}
