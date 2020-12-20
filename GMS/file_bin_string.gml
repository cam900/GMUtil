#define file_bin_read_variable_string
/// file_bin_read_variable_string(file);
// read variable size string from file

var f = argument0;
var in = file_bin_read_variable_unsigned(f);
var res = "";
while (in)
{
    res = chr(file_bin_read_variable_unsigned(f)) + res;
    in--;
}
return res;

#define file_bin_write_variable_string
/// file_bin_write_variable_string(file, string);
// write variable size string to file

var f = argument0;
var str = string(argument1);
file_bin_write_variable_unsigned(f, string_length(str));
while (str != "")
{
    var tmp = ord(string_char_at(str, string_length(str)));
    file_bin_write_variable_unsigned(f,tmp);
    str = string_copy(str, 1, string_length(str) - 1);
}


