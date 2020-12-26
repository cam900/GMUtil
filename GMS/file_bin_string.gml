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


#define file_bin_write_variable_base64
/// file_bin_write_variable_base64(file, base64);
// write variable size base64 format string to file

var f, str;
f = argument0;                                                                // file id
str = string(argument1);                                                      // base64 to file
if (str == "")                                                                // empty?
{
    file_bin_write_byte(f,0);
}
else
{
    var b64, out, siz;
    b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"; // base64 table for convert
    siz = 0;                                                                  // data size
    out = 0;                                                                  // output value
    while (str != "")                                                         // convert to integer and write
    {
        var tmp, tst;
        tst = string_char_at(str, string_length(str));
        if (tst != "=")                                                       // padding
        {
            tmp = (string_pos(tst, b64) - 1);
            out |= tmp << siz;
            siz += 6;
            while (siz >= 7)
            {
                file_bin_write_byte(f, $80 | (out & $7f));
                siz -= 7;
                out = out >> 7;
            }
        }
        str = string_copy(str, 1, string_length(str) - 1);
    }
    file_bin_write_byte(f, out & $7f);
}


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

#define file_bin_read_variable_base64
/// file_bin_read_variable_base64(file, [padding]);
// read variable size base64 format string from file

var f, in, siz, str, b64val;
f = argument[0];                                                           // file id
in = file_bin_read_byte(f);                                                // input data from file
siz = 8;                                                                   // data size
str = "";                                                                  // output string
b64val = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"; // base64 table for convert
if (in & $80)                                                              // multibyte data?
{
    var b64in;
    b64in = in & $7f;                                                      // input data
    siz = 7;                                                               // 7 bit
    while (in & $80)                                                       // get base64 and convert
    {
        while (siz >= 6)
        {
            str = string_char_at(b64val, (b64in & $3f) + 1) + str;
            b64in = b64in >> 6;
            siz -= 6;
        }
        in = file_bin_read_byte(f);
        b64in |= (in & $7f) << siz;
        siz += 7;
    }
    while (siz >= 6)                                                       // flush remains
    {
        str = string_char_at(b64val, (b64in & $3f) + 1) + str;
        b64in = b64in >> 6;
        siz -= 6;
    }
}
else
{
    while (siz >= 6)                                                       // get base64 and convert
    {
        str = string_char_at(b64val, (in & $3f) + 1) + str;
        in = in >> 6;
        siz -= 6;
    }
}
if ((argument_count == 2) && argument[1])                                  // optional padding flag
{
    while (string_length(str) & 3)
    {
        str += "=";
    }
}
return str;

