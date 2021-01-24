
///pivot_x(offset_x, offset_y, scale_x, scale_y, angle)
///pivot_y(offset_x, offset_y, scale_x, scale_y, angle)
// get pivot X/Y point calculated from object position

function pivot_x(offset_x, offset_y, scale_x, scale_y, angle){
	return lengthdir_x(offset_x * scale_x, angle) + lengthdir_x(offset_y * scale_y, angle - 90);
}

function pivot_y(offset_x, offset_y, scale_x, scale_y, angle){
	return lengthdir_y(offset_x * scale_x, angle) + lengthdir_y(offset_y * scale_y, angle - 90);
}