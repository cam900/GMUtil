#define file_bin_write_variable_string
/// file_bin_write_variable_string(file, string);
// write variable size string to file
// return size

var f, str, tmp, ret;
f = argument0;                                                 // file id
str = string(argument1);                                       // string for write
ret = file_bin_write_variable_unsigned(f, string_length(str)); // write length first
while (str != "") // write string
{
    tmp = ord(string_char_at(str, 1));                 // get each character
    file_bin_write_byte(f,tmp);                        // write, file_bin_write_byte because GM8 support single byte character only
    str = string_copy(str, 2, string_length(str) - 1); // flush last
    ret += 1;                                          // get size
}
return ret;

#define file_bin_write_variable_hexstring
/// file_bin_write_variable_hexstring(file, hexstring);
// write variable size hexadecimal or decimal format string to file
// return size

var f, str;
f = argument0;                 // file id
str = string_upper(argument1); // hexadecimal to file
if (str == "") // empty?
{
    file_bin_write_byte(f,0);
    return 1;
}
else
{
    var hxv, out, siz, ret, endflag;
    hxv = "0123456789ABCDEF"; // hexadecimal table for convert
    siz = 0;                  // data size
    out = 0;                  // output value
    ret = 0;                  // return value (size)
    endflag = $80;            // end flag?
    while (str != "")         // convert to integer and write
    {
        var tmp;
        tmp = (string_pos(string_char_at(str, 1), hxv) - 1);
        out |= tmp << siz;
        siz += 4;
        while (siz >= 7)
        {
            siz -= 7;
            if ((string_length(str) <= 1) && (siz < 7)) // last character?
            {
                endflag = 0;
            }
            file_bin_write_byte(f, endflag | (out & $7f));
            out = out >> 7;
            ret += 1;
        }
        str = string_copy(str, 2, string_length(str) - 1);
    }
    if (endflag & $80) // flush remains
    {
        file_bin_write_byte(f, out & $7f);
        ret += 1;
    }
    return ret;
}


#define file_bin_write_variable_base64
/// file_bin_write_variable_base64(file, base64);
// write variable size base64 format string to file
// return size

var f, str;
f = argument0;           // file id
str = string(argument1); // base64 to file
while (string_char_at(str, string_length(str)) == "=") // remove padding
{
    str = string_copy(str, 1, string_length(str) - 1);
}
if (str == "") // empty?
{
    file_bin_write_byte(f,0);
    return 1;
}
else
{
    var b64, out, siz, ret, endflag;
    b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"; // base64 table for convert
    siz = 0;                                                                  // data size
    out = 0;                                                                  // output value
    ret = 0;                                                                  // return value (size)
    endflag = $80;                                                            // end flag?
    while (str != "")                                                         // convert to integer and write
    {
        var tmp;
        tmp = string_pos(string_char_at(str, 1), b64) - 1;
        out |= tmp << siz;
        siz += 6;
        while (siz >= 7)
        {
            siz -= 7;
            if ((string_length(str) <= 1) && (siz < 7)) // last character?
            {
                endflag = 0;
            }
            file_bin_write_byte(f, endflag | (out & $7f));
            out = out >> 7;
            ret += 1;
        }
        str = string_copy(str, 2, string_length(str) - 1);
    }
    if (endflag & $80) // flush remains
    {
        file_bin_write_byte(f, out & $7f);
        ret += 1;
    }
    return ret;
}


#define file_bin_read_variable_string
/// file_bin_read_variable_string(file);
// read variable size string from file

var f, in, res;
f = argument0;                           // file id
in = file_bin_read_variable_unsigned(f); // get length
res = "";                                // string output
repeat (in) // read string
{
    res += chr(file_bin_read_byte(f)); // get each character, file_bin_read_byte because GM8 support single byte character only
}
return res; // output

#define file_bin_read_variable_hexstring
/// file_bin_read_variable_hexstring(file, [lower]);
// read variable size hexadecimal or decimal format string from file

var f, in, siz, str, hexval;
f = argument0;               // file id
in = file_bin_read_byte(f);  // input data from file
siz = 7;                     // data size
str = "";                    // output string
hexval = "0123456789ABCDEF"; // hexadecimal table for convert
if (in & $80) // multibyte data?
{
    var hexin;
    hexin = in & $7f; // input data
    siz = 7;          // 8 bit
    while (in & $80) // get hexadecimal and convert
    {
        while (siz >= 4)
        {
            str += string_char_at(hexval, (hexin & $f) + 1);
            hexin = hexin >> 4;
            siz -= 4;
        }
        in = file_bin_read_byte(f);
        hexin |= (in & $7f) << siz;
        siz += 7;
    }
    while (siz >= 4) // flush remains
    {
        str += string_char_at(hexval, (hexin & $f) + 1);
        hexin = hexin >> 4;
        siz -= 4;
    }
}
else
{
    while (siz >= 4) // get hexadecimal and convert
    {
        str += string_char_at(hexval, (in & $f) + 1);
        in = in >> 4;
        siz -= 4;
    }
}
if (argument1) // optional lower case flag
{
    str = string_lower(str);
}
return str;

#define file_bin_read_variable_base64
/// file_bin_read_variable_base64(file, [padding]);
// read variable size base64 format string from file

var f, in, siz, str, b64val;
f = argument0;                                                               // file id
in = file_bin_read_byte(f);                                                  // input data from file
siz = 8;                                                                     // data size
str = "";                                                                    // output string
b64val = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"; // base64 table for convert
if (in & $80)                                                                // multibyte data?
{
    var b64in;
    b64in = in & $7f; // input data
    siz = 7;          // 7 bit
    while (in & $80) // get base64 and convert
    {
        while (siz >= 6)
        {
            str += string_char_at(b64val, (b64in & $3f) + 1);
            b64in = b64in >> 6;
            siz -= 6;
        }
        in = file_bin_read_byte(f);
        b64in |= (in & $7f) << siz;
        siz += 7;
    }
    while (siz >= 6) // flush remains
    {
        str += string_char_at(b64val, (b64in & $3f) + 1);
        b64in = b64in >> 6;
        siz -= 6;
    }
}
else
{
    while (siz >= 6) // get base64 and convert
    {
        str += string_char_at(b64val, (in & $3f) + 1);
        in = in >> 6;
        siz -= 6;
    }
}
if (argument1) // optional padding flag
{
    while (string_length(str) & 3) // padding
    {
        str += "=";
    }
}
return str;

