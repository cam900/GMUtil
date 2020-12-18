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

