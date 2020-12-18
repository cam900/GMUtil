#define file_bin_read_variable_string
/// file_bin_read_variable_string(file);
// read variable size string from file

var f, in;
f = argument0;              // file id
in = file_bin_read_byte(f); // data from file
if (in < $80)
{
    return chr(in);
}
else
{
    var st, tmp, bstr;
    st = "";
    tmp = in & $7f;
    bstr = 7;
    while (in & $80)
    {
        in = file_bin_read_byte(f);
        tmp += (in & $7f) << bstr;
        bstr += 7;
        if (bstr >= 8)
        {
            st = chr(tmp & $ff) + st;
            tmp = tmp >> 8;
            bstr -= 8;
        }
    }
    while (bstr >= 8)
    {
        st = chr(tmp & $ff) + st;
        tmp = tmp >> 8;
        bstr -= 8;
    }
    return st;
}

#define file_bin_write_variable_string
/// file_bin_write_variable_string(file, string);
// write variable size string to file

var f, str, b;
f = argument0;           // file id
str = string(argument1); // data to file
if (str == "") // empty?
{
    file_bin_write_byte(f, b);
}
else
{
    b = ord(string_char_at(str, string_length(str)));
    if (b < $80 && (string_length(str) == 1)) // Single ASCII character: Single byte
    {
        file_bin_write_byte(f, b);
    }
    else
    {
        var strb;
        strb = 8;
        b = 0;
        while (strb > 7)
        {
            if ((strb < 24) && (str != ""))
            {
                b += ord(string_char_at(str, string_length(str))) << strb;
                str = string_copy(str, 0, string_length(str) - 1);
                strb += 8;
            }
            file_bin_write_byte(f, $80 | (b & $7f));
            b = (b >> 7);
            strb -= 7;
        }
        file_bin_write_byte(f, b & $7f);
    }
}


