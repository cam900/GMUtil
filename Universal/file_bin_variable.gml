#define file_bin_write_variable_unsigned
/// file_bin_write_variable_unsigned(file, variable);
// write variable size unsigned value to file (little endian)
// return size

var f, in;
f = argument0;  // file id
in = argument1; // data to file
if (in < $80) // 0-7f : Single byte
{
    file_bin_write_byte(f,in);
    return 1;
}
else // 80 or larger: Multi byte
{
    var adj, prv, tmp, siz, ret;
    tmp = $80;
    adj = 7;
    siz = 0;
    ret = 0;
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
        ret += 1;
    }
    file_bin_write_byte(f, in & $7f);
    ret += 1;
    return ret;
}


#define file_bin_write_variable_signed
/// file_bin_write_variable_signed(file, variable);
// write variable size signed value to file (little endian)
// bit 6 of first byte is sign bit
// return size

var f, in, flag;
f = argument0;  // file id
in = argument1; // data to file
flag = 0;       // sign bit
if (in < 0) // input is negative?
{
    in = -(in + 1);
    flag = $40;
}
// convert to unsigned
in = (in & $3f) | ((in & ~$3f) << 1) | flag;
return file_bin_write_variable_unsigned(f,in);

#define file_bin_write_variable_fraction
/// file_bin_write_variable_fraction(file, variable);
// write variable size fraction value to file
// return size

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
return file_bin_write_variable_unsigned(f,out);

#define file_bin_write_variable_unsigned_frac
/// file_bin_write_variable_unsigned_frac(file, variable);
// write variable size unsigned value to file (little endian, with fraction)
// bit 6 of first byte is fraction bit
// return size

var f, in, flag, fracval, ret;
f = argument0;      // file id
in = argument1;     // data to file
flag = 0;           // fraction bit
fracval = frac(in); // fraction value
ret = 0;            // return value (size)
if (fracval > 0) // fraction value is larger than 0?
{
    flag = $40;
    in = floor(in);
}
// convert to unsigned
in = (in & $3f) | ((in & ~$3f) << 1) | flag;
ret += file_bin_write_variable_unsigned(f,in);
if (flag)
{
    ret += file_bin_write_variable_fraction(f,fracval);
}
return ret;

#define file_bin_write_variable_signed_frac
/// file_bin_write_variable_signed_frac(file, variable);
// write variable size signed value to file (little endian, with fraction)
// bit 6 of first byte is sign bit
// bit 5 of first byte is fraction bit
// return size

var f, in, flag, fracval, ret;
f = argument0;  // file id
in = argument1; // data to file
flag = 0;       // sign and fraction bit
ret = 0;        // return value (size)
if (in < 0) // input is negative?
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
ret += file_bin_write_variable_unsigned(f,in);
if (flag & $20)
{
    ret += file_bin_write_variable_fraction(f,fracval);
}
return ret;

#define file_bin_read_variable_unsigned
/// file_bin_read_variable_unsigned(file);
// read variable size unsigned value from file (little endian)

var f, in;
f = argument0;              // file id
in = file_bin_read_byte(f); // data from file
if (in & $80) // multi-byte flag?
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

#define file_bin_copy
/// file_bin_copy(srcfile, destfile);
// copy srcfile to destfile
var src, dst, size;
src = file_bin_open(argument0, 0);         // copy source
dst = file_bin_open(argument1, 1);         // destination
size = file_bin_size(src);                 // size of file
repeat (size) // copy each bytes
{
    file_bin_write_byte(dst, file_bin_read_byte(src));
}
file_bin_close(dst);
file_bin_close(src);

#define file_bin_import_file
/// file_bin_import_file(fileid, srcfile);
// import variable size file to already opened file id
var f, src, size;
f = argument0;                            // import destination
src = file_bin_open(argument1, 0);        // source file
size = file_bin_size(src);                // size of source file
file_bin_write_variable_unsigned(f,size); // write size first (variable size unsigned format)
repeat (size) // copy each bytes
{
    file_bin_write_byte(f, file_bin_read_byte(src));
}
file_bin_close(src);

#define file_bin_import_file_rle
/// file_bin_import_file_rle(fileid, srcfile);
// RLE compress and import variable size file to already opened file id
var f, src, size, tmp;
f = argument0;                     // import destination
src = file_bin_open(argument1, 0); // source file
tmp = file_bin_open_temp("rle"); // temporary file used to RLE buffer
size = rle_compress_file(src, tmp);       // size of source file
file_bin_write_variable_unsigned(f,size); // write size first (variable size unsigned format)
file_bin_seek(tmp, 0);
repeat (size) // copy each bytes
{
    file_bin_write_byte(f, file_bin_read_byte(tmp));
}
file_bin_close_temp(tmp, "rle");
file_bin_close(src);

#define file_bin_import_file_drle
/// file_bin_import_file_drle(fileid, srcfile);
// Delta RLE compress and import variable size file to already opened file id
var f, src, size, tmp;
f = argument0;                     // import destination
src = file_bin_open(argument1, 0); // source file
tmp = file_bin_open_temp("rle"); // temporary file used to RLE buffer
size = drle_compress_file(src, tmp);      // size of source file
file_bin_write_variable_unsigned(f,size); // write size first (variable size unsigned format)
file_bin_seek(tmp, 0);
repeat (size) // copy each bytes
{
    file_bin_write_byte(f, file_bin_read_byte(tmp));
}
file_bin_close_temp(tmp, "rle");
file_bin_close(src);

#define file_bin_import_file_string
/// file_bin_import_file_string(fileid, srcfile);
// import variable size file to already opened file id, with filename
var f, src;
f = argument0;                          // import destination
src = string(argument1);                // filename
file_bin_write_variable_string(f, src); // write filename string
file_bin_import_file(f, src);           // and import

#define file_bin_import_file_string_rle
/// file_bin_import_file_string_rle(fileid, srcfile);
// RLE compress and import variable size file to already opened file id, with filename
var f, src;
f = argument0;                          // import destination
src = string(argument1);                // filename
file_bin_write_variable_string(f, src); // write filename string
file_bin_import_file_rle(f, src);       // and import

#define file_bin_import_file_string_drle
/// file_bin_import_file_string_drle(fileid, srcfile);
// Delta RLE compress and import variable size file to already opened file id, with filename
var f, src;
f = argument0;                          // import destination
src = string(argument1);                // filename
file_bin_write_variable_string(f, src); // write filename string
file_bin_import_file_drle(f, src);      // and import

#define file_bin_export_file
/// file_bin_export_file(fileid, dstfile);
// export variable size file from already opened file id
var f, dst, size;
f = argument0;                             // export source
dst = file_bin_open(argument1, 1);         // destination
size = file_bin_read_variable_unsigned(f); // size of file
repeat (size) // copy each bytes
{
    file_bin_write_byte(dst, file_bin_read_byte(f));
}
file_bin_close(dst);

#define file_bin_export_file_rle
/// file_bin_export_file_rle(fileid, dstfile);
// export and RLE decompress variable size file from already opened file id
var f, dst, size, tmp;
f = argument0;                             // export source
dst = file_bin_open(argument1, 1);         // destination
tmp = file_bin_open_temp("rle"); // temporary file used to RLE buffer
size = file_bin_read_variable_unsigned(f); // size of file
repeat (size) // copy each bytes
{
    file_bin_write_byte(tmp, file_bin_read_byte(f));
}
file_bin_seek(tmp, 0);
rle_decompress_file(tmp, dst);
file_bin_close_temp(tmp, "rle");
file_bin_close(dst);

#define file_bin_export_file_drle
/// file_bin_export_file_drle(fileid, dstfile);
// export and Delta RLE decompress variable size file from already opened file id
var f, dst, size, tmp;
f = argument0;                             // export source
dst = file_bin_open(argument1, 1);         // destination
tmp = file_bin_open_temp("rle"); // temporary file used to RLE buffer
size = file_bin_read_variable_unsigned(f); // size of file
repeat (size) // copy each bytes
{
    file_bin_write_byte(tmp, file_bin_read_byte(f));
}
file_bin_seek(tmp, 0);
drle_decompress_file(tmp, dst);
file_bin_close_temp(tmp, "rle");
file_bin_close(dst);

#define file_bin_export_file_string
/// file_bin_export_file_string(fileid);
// export variable size file from already opened file id, with filename
var f, dst;
f = argument0;                          // export source
dst = file_bin_read_variable_string(f); // get filename to export
file_bin_export_file(f, dst);           // and export

#define file_bin_export_file_string_rle
/// file_bin_export_file_string_rle(fileid);
// export and RLE decompress variable size file from already opened file id, with filename
var f, dst;
f = argument0;                          // export source
dst = file_bin_read_variable_string(f); // get filename to export
file_bin_export_file_rle(f, dst);       // and export

#define file_bin_export_file_string_drle
/// file_bin_export_file_string_drle(fileid);
// export and Delta RLE decompress variable size file from already opened file id, with filename
var f, dst;
f = argument0;                          // export source
dst = file_bin_read_variable_string(f); // get filename to export
file_bin_export_file_drle(f, dst);      // and export

#define file_bin_compress_rle
/// file_bin_compress_rle(srcfile, destfile);
// compress file into RLE algorithm and output to destfile
// return size

var fin, fout, ret;
fin = file_bin_open(argument0, 0);
fout = file_bin_open(argument1, 1);
ret = rle_compress_file(fin, fout);
file_bin_close(fin);
file_bin_close(fout);
return ret;

#define file_bin_compress_drle
/// file_bin_compress_drle(srcfile, destfile);
// compress file into Delta RLE algorithm and output to destfile
// return size

var fin, fout, ret;
fin = file_bin_open(argument0, 0);
fout = file_bin_open(argument1, 1);
ret = drle_compress_file(fin,fout);
file_bin_close(fin);
file_bin_close(fout);
return ret;

#define file_bin_decompress_rle
/// file_bin_decompress_rle(srcfile, destfile);
// decompress RLE compressed file and output to destfile
// return size

var fin, fout, ret;
fin = file_bin_open(argument0, 0);
fout = file_bin_open(argument1, 1);
ret = rle_decompress_file(fin,fout);
file_bin_close(fin);
file_bin_close(fout);
return ret;

#define file_bin_decompress_drle
/// file_bin_decompress_drle(srcfile, destfile);
// decompress Delta RLE compressed file and output to destfile
// return size

var fin, fout, ret;
fin = file_bin_open(argument0, 0);
fout = file_bin_open(argument1, 1);
ret = drle_decompress_file(fin,fout);
file_bin_close(fin);
file_bin_close(fout);
return ret;

#define rle_compress_file
/// rle_compress_file(srcfile, destfile);
// RLE compress srcfile data and write result to destfile
// return size

var fin, fout, curr, prev, repval, ret;
fin = argument0;
fout = argument1;
curr = 0;
prev = -1;
repval = 0;
ret = 0;

while (file_bin_position(fin) < file_bin_size(fin))
{
    curr = file_bin_read_byte(fin);
    if (curr != prev) // new value
    {
        if (repval > 0)
        {
            ret += file_bin_write_variable_unsigned(fout, repval - 1);
            repval = 0;
        }
        file_bin_write_byte(fout, curr);
        ret += 1;
    }
    else // repeated value
    {
        if (repval <= 0)
        {
            file_bin_write_byte(fout, curr);
            ret += 1;
        }
        repval += 1;
    }
    prev = curr;
}
// flush RLE when EOF
if (repval > 0)
{
    ret += file_bin_write_variable_unsigned(fout, repval - 1);
    repval = 0;
}

return ret;

#define rle_decompress_file
/// rle_decompress_file(srcfile, destfile);
// decompress RLE compressed srcfile data and write result to destfile
// return size

var fin, fout, curr, prev, repval, ret;
fin = argument0;
fout = argument1;
curr = 0;
prev = -1;
repval = 0;
ret = 0;

while (file_bin_position(fin) < file_bin_size(fin))
{
    curr = file_bin_read_byte(fin);
    file_bin_write_byte(fout, curr);
    ret += 1;
    if (curr == prev) // repeated value
    {
        repval = file_bin_read_variable_unsigned(fin);
        if (repval > 0)
        {
                repeat (repval)
                {
                    file_bin_write_byte(fout, curr);
                    ret += 1;
                }
        }
    }
    prev = curr;
}
return ret;

#define drle_compress_file
/// drle_compress_file(srcfile, destfile);
// Delta RLE compress srcfile data and write result to destfile
// return size

var fin, fout, curr, prev, dcur, dprv, repval, ret;
fin = argument0;
fout = argument1;
curr = 0;
prev = -1;
dcur = 0;
dprv = 0;
repval = 0;
ret = 0;

while (file_bin_position(fin) < file_bin_size(fin))
{
    dcur = file_bin_read_byte(fin);
    curr = ((dcur - dprv) + 256) & $ff;
    dprv = dcur;
    if (curr != prev) // new value
    {
        if (repval > 0)
        {
            ret += file_bin_write_variable_unsigned(fout, repval - 1);
            repval = 0;
        }
        file_bin_write_byte(fout, curr);
        ret += 1;
    }
    else // repeated value
    {
        if (repval <= 0)
        {
            file_bin_write_byte(fout, curr);
            ret += 1;
        }
        repval += 1;
    }
    prev = curr;
}
// flush DRLE when EOF
if (repval > 0)
{
    ret += file_bin_write_variable_unsigned(fout, repval - 1);
    repval = 0;
}
return ret;

#define drle_decompress_file
/// drle_decompress_file(srcfile, destfile);
// decompress Delta RLE compressed srcfile data and write result to destfile
// return size

var fin, fout, dbuf, curr, prev, repval, ret;
fin = argument0;
fout = argument1;
dbuf = 0;
curr = 0;
prev = -1;
repval = 0;
ret = 0;

while (file_bin_position(fin) < file_bin_size(fin))
{
    curr = file_bin_read_byte(fin);
    dbuf += curr;
    file_bin_write_byte(fout, dbuf);
    ret += 1;
    if (curr == prev) // repeated value
    {
        repval = file_bin_read_variable_unsigned(fin);
        if (repval > 0)
        {
            repeat (repval)
            {
                dbuf += curr;
                file_bin_write_byte(fout, dbuf);
                ret += 1;
            }
        }
    }
    prev = curr;
}
return ret;

#define file_bin_open_temp
/// file_bin_open_temp(prefix);
// open temporary buffer file, return id
var f,;
f = file_bin_open(temp_directory + "\" + string(argument0) + "_temp", 2); // open temporary file
file_bin_rewrite(f); // clear before use it
return f;

#define file_bin_close_temp
/// file_bin_close_temp(fileid, prefix);
// close temporary buffer file
var f;
f = argument0;
file_bin_rewrite(f); // clear before close for some protection purpose
file_bin_close(f);
file_delete(temp_directory + "\"+string(argument1)+"_temp"); // delete closed buffer, also for some protection purpose

