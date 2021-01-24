#define pivot_x
///pivot_x(offset_x, offset_y, scale_x, scale_y, angle)
// get pivot X point calculated from object position
var offset_x, offset_y, scale_x, scale_y, angle;
offset_x = argument0;
offset_y = argument1;
scale_x = argument2;
scale_y = argument3;
angle = argument3;
return lengthdir_x(offset_x * scale_x, angle) + lengthdir_x(offset_y * scale_y, angle - 90);

#define pivot_y
///pivot_y(offset_x, offset_y, scale_x, scale_y, angle)
// get pivot Y point calculated from object position
var offset_x, offset_y, scale_x, scale_y, angle;
offset_x = argument0;
offset_y = argument1;
scale_x = argument2;
scale_y = argument3;
angle = argument3;
return lengthdir_y(offset_x * scale_x, angle) + lengthdir_y(offset_y * scale_y, angle - 90);

