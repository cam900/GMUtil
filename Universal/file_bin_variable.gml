#define file_bin_write_variable_unsigned
/// file_bin_write_variable_unsigned(file, variable);
// write variable size unsigned value to file (little endian)

var f, in;
f = argument0;  // file id
in = argument1; // data to file
if (in < $80)   // 0-7f : Single byte
{
    file_bin_write_byte(f,in);
}
else            // larger: Multi byte
{
    var adj, prv, tmp, siz;
    tmp = $80;
    adj = 7;
    siz = 0;
    while (in >= tmp)
    {
        prv = tmp;
        siz += 1;
        adj += 7;
        tmp += 1 << adj;
    }
    in -= prv;
    while (siz)
    {
        file_bin_write_byte(f, $80 | (in & $7f));
        siz -= 1;
        in = in >> 7;
    }
    file_bin_write_byte(f, in & $7f);
}


#define file_bin_write_variable_signed
/// file_bin_write_variable_signed(file, variable);
// write variable size signed value to file (little endian)
// bit 6 of first byte is sign bit

var f, in, flag;
f = argument0;  // file id
in = argument1; // data to file
flag = 0;       // sign bit
if (in < 0)     // input is negative?
{
    in = -(in + 1);
    flag = $40;
}
// convert to unsigned
in = (in & $3f) | ((in & ~$3f) << 1) | flag;
file_bin_write_variable_unsigned(f,in);

#define file_bin_write_variable_fraction
/// file_bin_write_variable_fraction(file, variable);
// write variable size fraction value to file

var f,in,out,pos,bpos;
f = argument0;         // file id
in = frac(argument1);  // data to file
out = 0;               // output value
bpos = 0;              // bit position
pos = 1;               // fraction position
// repeat while fraction bit is remains
while (in > 0)
{
    pos /= 2;
    if (in >= pos)
    {
        in -= pos;
        out |= (1 << bpos);
    }
    bpos += 1;
}
file_bin_write_variable_unsigned(f,out);

#define file_bin_write_variable_unsigned_frac
/// file_bin_write_variable_unsigned_frac(file, variable);
// write variable size unsigned value to file (little endian, with fraction)
// bit 6 of first byte is fraction bit

var f, in, flag, fracval;
f = argument0;      // file id
in = argument1;     // data to file
flag = 0;           // fraction bit
fracval = frac(in); // fraction value
if (fracval > 0)    // fraction value is larger than 0?
{
    flag = $40;
    in = floor(in);
}
// convert to unsigned
in = (in & $3f) | ((in & ~$3f) << 1) | flag;
file_bin_write_variable_unsigned(f,in);
if (flag)
{
    file_bin_write_variable_fraction(f,fracval);
}

#define file_bin_write_variable_signed_frac
/// file_bin_write_variable_signed_frac(file, variable);
// write variable size signed value to file (little endian, with fraction)
// bit 6 of first byte is sign bit
// bit 5 of first byte is fraction bit

var f, in, flag, fracval;
f = argument0;  // file id
in = argument1; // data to file
flag = 0;       // sign and fraction bit
if (in < 0)     // input is negative?
{
    in = -(in + 1);
    flag |= $40;
}
fracval = frac(in);
if (fracval > 0) // fraction value is larger than 0?
{
    flag |= $20;
    in = floor(in);
}
// convert to unsigned
in = (in & $1f) | ((in & ~$1f) << 2) | flag;
file_bin_write_variable_unsigned(f,in);
if (flag & $20)
{
    file_bin_write_variable_fraction(f,fracval);
}

#define file_bin_write_variable_hexstring
/// file_bin_write_variable_hexstring(file, hexstring);
// write variable size hexadecimal or decimal format string to file

var f, str;
f = argument0;                 // file id
str = string_upper(argument1); // hexadecimal to file
if (str == "")                 // empty?
{
    file_bin_write_byte(f,0);
}
else
{
    var hxv, out, siz;
    hxv = "0123456789ABCDEF";   // hexadecimal table for convert
    siz = 0;                    // data size
    out = 0;                    // output value
    while (str != "")           // convert to integer and write
    {
        var tmp;
        tmp = (string_pos(string_char_at(str, string_length(str)), hxv) - 1);
        out |= tmp << siz;
        siz += 4;
        while (siz >= 7)
        {
            file_bin_write_byte(f, $80 | (out & $7f));
            siz -= 7;
            out = out >> 7;
        }
        str = string_copy(str, 1, string_length(str) - 1);
    }
    file_bin_write_byte(f, out & $7f);
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


#define file_bin_read_variable_unsigned
/// file_bin_read_variable_unsigned(file);
// read variable size unsigned value from file (little endian)

var f, in;
f = argument0;              // file id
in = file_bin_read_byte(f); // data from file
if (in & $80)               // multi-byte flag?
{
    var res, adj;
    res = in & $7f;
    adj = 7;
    while (in & $80) // continuous data?
    {
        in = file_bin_read_byte(f); // fetch next byte
        res += ((in & $7f) << adj) + (1 << adj); // add to result
        adj += 7;
    }
    return res;
}

return in;

#define file_bin_read_variable_signed
/// file_bin_read_variable_signed(file);
// read variable size signed value from file (little endian)
// bit 6 of first byte is sign bit

var f, in, flag;
f = argument0;                           // file id
in = file_bin_read_variable_unsigned(f); // data from file
flag = in & $40;                         // sign bit
// convert to signed
in = (in & $3f) | ((in & ~$7f) >> 1);
if (flag)
{
    in = (-in) - 1;
}
return in;

#define file_bin_read_variable_fraction
/// file_bin_read_variable_fraction(file);
// read variable size fraction value from file

var f, in, out, bpos;
f = argument0;                           // file id
in = file_bin_read_variable_unsigned(f); // data from file
out = 0;                                 // output value
bpos = 0;                                // bit position
// repeat while fraction bit is remains
while (in > 0)
{
    if (in & 1)
    {
        out += (1 / (2 << bpos));
    }
    in = in >> 1;
    bpos += 1;
}
return out;

#define file_bin_read_variable_unsigned_frac
/// file_bin_read_variable_unsigned_frac(file);
// read variable size unsigned value from file (little endian, with fraction)
// bit 6 of first byte is fraction bit

var f, in, flag;
f = argument0;                           // file id
in = file_bin_read_variable_unsigned(f); // data from file
flag = in & $40;                         // fraction bit
// convert to real
in = (in & $3f) | ((in & ~$7f) >> 1);
if (flag)
{
    in += file_bin_read_variable_fraction(f);
}
return in;

#define file_bin_read_variable_signed_frac
/// file_bin_read_variable_signed_frac(file);
// read variable size signed value from file (little endian, with fraction)
// bit 6 of first byte is sign bit
// bit 5 of first byte is fraction bit

var f, in, flag;
f = argument0;                           // file id
in = file_bin_read_variable_unsigned(f); // data from file
flag = in & $60;                         // sign and fraction bit
// convert to signed
in = (in & $1f) | ((in & ~$7f) >> 2);
if (flag & $20) // fraction?
{
    in += file_bin_read_variable_fraction(f);
}
if (flag & $40) // signed?
{
    in = (-in) - 1;
}
return in;

#define file_bin_read_variable_hexstring
/// file_bin_read_variable_hexstring(file, [lower]);
// read variable size hexadecimal or decimal format string from file

var f, in, siz, str, hexval;
f = argument0;               // file id
in = file_bin_read_byte(f);  // input data from file
siz = 7;                     // data size
str = "";                    // output string
hexval = "0123456789ABCDEF"; // hexadecimal table for convert
if (in & $80)                // multibyte data?
{
    var hexin;
    hexin = in & $7f;        // input data
    siz = 7;                 // 8 bit
    while (in & $80)         // get hexadecimal and convert
    {
        while (siz >= 4)
        {
            str = string_char_at(hexval, (hexin & $f) + 1) + str;
            hexin = hexin >> 4;
            siz -= 4;
        }
        in = file_bin_read_byte(f);
        hexin |= (in & $7f) << siz;
        siz += 7;
    }
    while (siz >= 4)         // flush remains
    {
        str = string_char_at(hexval, (hexin & $f) + 1) + str;
        hexin = hexin >> 4;
        siz -= 4;
    }
}
else
{
    while (siz >= 4) // get hexadecimal and convert
    {
        str = string_char_at(hexval, (in & $f) + 1) + str;
        in = in >> 4;
        siz -= 4;
    }
}
if (argument1)               // optional lower case flag
{
    str = string_lower(str);
}
return str;

#define file_bin_read_variable_base64
/// file_bin_read_variable_base64(file, [padding]);
// read variable size base64 format string from file

var f, in, siz, str, b64val;
f = argument0;                                                             // file id
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
    while (siz >= 6)         // flush remains
    {
        str = string_char_at(b64val, (b64in & $3f) + 1) + str;
        b64in = b64in >> 6;
        siz -= 6;
    }
}
else
{
    while (siz >= 6) // get base64 and convert
    {
        str = string_char_at(b64val, (in & $3f) + 1) + str;
        in = in >> 6;
        siz -= 6;
    }
}
if (argument1)               // optional padding flag
{
    while (string_length(str) & 3)
    {
        str += "=";
    }
}
return str;

#define file_bin_import_file
/// file_bin_import_file(fileid, srcfile);
// import variable size file to already opened file id
var f, src, size;
f = argument0;                            // import destination
src = file_bin_open(argument1, 0);        // source file
size = file_bin_size(src);                // size of source file
file_bin_write_variable_unsigned(f,size); // write size first (variable size unsigned format)
repeat (size)                             // copy each bytes
{
    file_bin_write_byte(f, file_bin_read_byte(src));
}
file_bin_close(src);

#define file_bin_import_file_string
/// file_bin_import_file_string(fileid, srcfile);
// import variable size file to already opened file id, with filename
var f, src;
f = argument0;                          // import destination
src = string(argument1);                // filename
file_bin_write_variable_string(f, src); // write filename string
file_bin_import_file(f, src);           // and import

#define file_bin_export_file
/// file_bin_export_file(fileid, dstfile);
// export variable size file from already opened file id
var f, dst, size;
f = argument0;                             // export source
dst = file_bin_open(argument1, 1);         // destination
size = file_bin_read_variable_unsigned(f); // size of file
repeat (size)                              // copy each bytes
{
    file_bin_write_byte(dst, file_bin_read_byte(f));
}
file_bin_close(dst);

#define file_bin_export_file_string
/// file_bin_export_file_string(fileid);
// export variable size file from already opened file id, with filename
var f, dst;
f = argument0;                          // export source
dst = file_bin_read_variable_string(f); // get filename to export
file_bin_export_file(f, dst);           // and export

