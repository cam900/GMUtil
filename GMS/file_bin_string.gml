#define file_bin_read_variable_string
/// file_bin_read_variable_string(file);
// read variable size string from file

var f = argument0;
var in = file_bin_read_variable_unsigned(f);
var buff = buffer_create(in, buffer_grow, 1);
var pos = 0;
while (pos < buffer_get_size(buff))
{
    buffer_write(buff, buffer_u8, file_bin_read_byte(f));
    pos++;
}
buffer_seek(buff, buffer_seek_start, 0);
var res = buffer_read(buff, buffer_text);
buffer_delete(buff);
return res;

#define file_bin_write_variable_string
/// file_bin_write_variable_string(file, string);
// write variable size string to file

var f = argument0;
var str = string(argument1);
var buff = buffer_create(string_byte_length(str), buffer_grow, 1);
var pos = 0;
buffer_write(buff, buffer_text, str);
buffer_seek(buff, buffer_seek_start, 0);
file_bin_write_variable_unsigned(f, buffer_get_size(buff));
while (pos < buffer_get_size(buff))
{
    file_bin_write_byte(f, buffer_read(buff, buffer_u8));
    pos++;
}
buffer_delete(buff);

