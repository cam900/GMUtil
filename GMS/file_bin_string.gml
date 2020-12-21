#define file_bin_read_variable_string
/// file_bin_read_variable_string(file);
// read variable size string from file

var f = argument0;                                           // file for read
var in = file_bin_read_variable_unsigned(f);                 // get length
var res = "";                                                // string output
repeat (in)                                                  // read string
{
    res = chr(file_bin_read_variable_unsigned(f) + 1) + res; // get each character, +1 because $00 is end of string flag
}
return res;                                                  // output

#define file_bin_write_variable_string
/// file_bin_write_variable_string(file, string);
// write variable size string to file

var f = argument0;                                          // file id
var str = string(argument1);                                // string for write
file_bin_write_variable_unsigned(f, string_length(str));    // write length first
while (str != "")                                           // write string
{
    var tmp = ord(string_char_at(str, string_length(str))); // get each character
    file_bin_write_variable_unsigned(f,tmp - 1);            // write, -1 because $00 is end of string flag
    str = string_copy(str, 1, string_length(str) - 1);      // flush last
}


