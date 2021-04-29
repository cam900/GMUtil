#region // write data to file

#region // write variable size integer

/// file_bin_write_variable_unsigned(file, variable);
// write variable size unsigned value to file (little endian)

function file_bin_write_variable_unsigned(_f, _in)
{
	var f = _f;     // file id
	var in = _in;   // data to file
	if (in < $80) // 0-7f : Single byte
	{
		file_bin_write_byte(f,in);
		return 1;
	}
	else // 80 or larger: Multi byte
	{
		var prv = -1;
		var tmp = $80;
		var adj = 7;
		var siz = 0;
		var ret = 0;
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
}


/// file_bin_write_variable_signed(file, variable);
// write variable size signed value to file (little endian)
// bit 6 of first byte is sign bit

function file_bin_write_variable_signed(_f, _in)
{
	var f = _f;   // file id
	var in = _in; // data to file
	var flag = 0; // sign bit
	if (in < 0) // input is negative?
	{
		in = -(in + 1);
		flag = $40;
	}
	// convert to unsigned
	in = (in & $3f) | ((in & ~$3f) << 1) | flag;
	return file_bin_write_variable_unsigned(f,in);
}

#endregion

#region // write variable size real

/// file_bin_write_variable_fraction(file, variable);
// write variable size fraction value to file

function file_bin_write_variable_fraction(_f, _in)
{
	var f = _f;                // file id
	var in = frac(_in);        // data to file
	var out = 0;               // output value
	var bpos = 0;              // bit position
	var pos = 1;               // fraction position
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
}

/// file_bin_write_variable_unsigned_frac(file, variable);
// write variable size unsigned value to file (little endian, with fraction)
// bit 6 of first byte is fraction bit

function file_bin_write_variable_unsigned_frac(_f, _in)
{
	var f = _f;             // file id
	var in = _in;           // data to file
	var flag = 0;           // fraction bit
	var fracval = frac(in); // fraction value
	var ret = 0;            // return value (size)
	if (fracval > 0)        // fraction value is larger than 0?
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
}

/// file_bin_write_variable_signed_frac(file, variable);
// write variable size signed value to file (little endian, with fraction)
// bit 6 of first byte is sign bit
// bit 5 of first byte is fraction bit

function file_bin_write_variable_signed_frac(_f, _in)
{
	var f = _f;   // file id
	var in = _in; // data to file
	var flag = 0; // sign and fraction bit
	var ret = 0;  // return value (size)
	if (in < 0)   // input is negative?
	{
		in = -(in + 1);
		flag |= $40;
	}
	var fracval = frac(in);
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
}

#endregion

#region // write variable size strings

/// file_bin_write_variable_string(file, string);
// write variable size string to file

function file_bin_write_variable_string(_f, _str)
{
	var f = _f;                                                        // file id
	var str = string(_str);                                            // string for write
	var ret = file_bin_write_variable_unsigned(f, string_length(str)); // write length first
	while (str != "") // write string
	{
		var tmp = ord(string_char_at(str, 1));              // get each character
		ret += file_bin_write_variable_unsigned(f,tmp - 1); // write, -1 because $00 is end of string flag
		str = string_copy(str, 2, string_length(str) - 1);  // flush last
	}
	return ret;
}

/// file_bin_write_variable_hexstring(file, hexstring);
// write variable size hexadecimal or decimal format string to file

function file_bin_write_variable_hexstring(_f, _str)
{
	var f = _f;                   // file id
	var str = string_upper(_str); // hexadecimal to file
	if (str == "") // empty?
	{
		file_bin_write_byte(f,0);
		return 1;
	}
	else
	{
		var hxv = "0123456789ABCDEF"; // hexadecimal table for convert
		var siz = 0;                  // data size
		var out = 0;                  // output value
		var ret = 0;                  // return value (size)
		var endflag = $80;            // end flag?
		while (str != "") // convert to integer and write
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
				ret += 1;
				out = out >> 7;
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
}

/// file_bin_write_variable_base64(file, base64);
// write variable size base64 format string to file

function file_bin_write_variable_base64(_f, _str)
{
	var f = _f;             // file id
	var str = string(_str); // base64 to file
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
		var b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"; // base64 table for convert
		var siz = 0;                                                                  // data size
		var out = 0;                                                                  // output value
		var ret = 0;                                                                  // return value (size)
		var endflag = $80;                                                            // end flag?
		while (str != "") // convert to integer and write
		{
			var tmp = string_pos(string_char_at(str, 1), b64) - 1;
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
}

#endregion

#endregion

#region // read data from file

#region // read variable size integer

/// file_bin_read_variable_unsigned(file);
// read variable size unsigned value from file (little endian)

function file_bin_read_variable_unsigned(_f)
{
	var f = _f;                     // file id
	var in = file_bin_read_byte(f); // data from file
	if (in & $80)                   // multi-byte flag?
	{
		var res = in & $7f;
		var adj = 7;
		while (in & $80) // continuous data?
		{
			in = file_bin_read_byte(f); // fetch next byte
			res += ((in & $7f) << adj) + (1 << adj); // add to result
			adj += 7;
		}
		return res;
	}
	return in;
}

/// file_bin_read_variable_signed(file);
// read variable size signed value from file (little endian)
// bit 6 of first byte is sign bit

function file_bin_read_variable_signed(_f)
{
	var f = _f;                                  // file id
	var in = file_bin_read_variable_unsigned(f); // data from file
	var flag = in & $40;                         // sign bit
	// convert to signed
	in = (in & $3f) | ((in & ~$7f) >> 1);
	if (flag)
	{
		in = (-in) - 1;
	}
	return in;
}

#endregion

#region // read variable size real

/// file_bin_read_variable_fraction(file);
// read variable size fraction value from file

function file_bin_read_variable_fraction(_f)
{
	var f = _f;                                  // file id
	var in = file_bin_read_variable_unsigned(f); // data from file
	var out = 0;                                 // output value
	var bpos = 0;                                // bit position
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
}

/// file_bin_read_variable_unsigned_frac(file);
// read variable size unsigned value from file (little endian, with fraction)
// bit 6 of first byte is fraction bit

function file_bin_read_variable_unsigned_frac(_f)
{
	var f = _f;                                  // file id
	var in = file_bin_read_variable_unsigned(f); // data from file
	var flag = in & $40;                         // fraction bit
	// convert to real
	in = (in & $3f) | ((in & ~$7f) >> 1);
	if (flag)
	{
		in += file_bin_read_variable_fraction(f);
	}
	return in;
}

/// file_bin_read_variable_signed_frac(file);
// read variable size signed value from file (little endian, with fraction)
// bit 6 of first byte is sign bit
// bit 5 of first byte is fraction bit

function file_bin_read_variable_signed_frac(_f)
{
	var f = _f;                                  // file id
	var in = file_bin_read_variable_unsigned(f); // data from file
	var flag = in & $60;                         // sign and fraction bit
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
}

#endregion

#region // read variable size strings

/// file_bin_read_variable_string(file);
// read variable size string from file

function file_bin_read_variable_string(_f)
{
	var f = _f;                                  // file for read
	var in = file_bin_read_variable_unsigned(f); // get length
	var res = "";                                // string output
	repeat (in) // read string
	{
		res += chr(file_bin_read_variable_unsigned(f) + 1); // get each character, +1 because $00 is end of string flag
	}
	return res; // output
}

/// file_bin_read_variable_hexstring(file, [lower]);
// read variable size hexadecimal or decimal format string from file

function file_bin_read_variable_hexstring(_f, _low)
{
	var f = _f;                      // file id
	var in = file_bin_read_byte(f);  // input data from file
	var siz = 7;                     // data size
	var str = "";                    // output string
	var hexval = "0123456789ABCDEF"; // hexadecimal table for convert
	if (!is_undefined(_low)) // optional lower case flag
	{
		if (_low)
		{
			hexval = string_lower(hexval);
		}
	}
	if (in & $80) // multibyte data?
	{
		var hexin = in & $7f; // input data
		siz = 7;              // 7 bit
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
	return str;
}

/// file_bin_read_variable_base64(file, [padding]);
// read variable size base64 format string from file

function file_bin_read_variable_base64(_f, _padding)
{
	var f = _f;                                                                      // file id
	var in = file_bin_read_byte(f);                                                  // input data from file
	var siz = 8;                                                                     // data size
	var str = "";                                                                    // output string
	var b64val = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"; // base64 table for convert
	if (in & $80) // multibyte data?
	{
		var b64in = in & $7f; // input data
		siz = 7;              // 7 bit
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
	if (!is_undefined(_padding)) // optional padding flag
	{
		if (_padding)
		{
			while (string_length(str) & 3) // padding
			{
				str += "=";
			}
		}
	}
	return str;
}

#endregion

#endregion

#region // file handlers

/// file_bin_copy(srcfile, destfile);
// copy srcfile to destfile

function file_bin_copy(_src, _dst)
{
var src = file_bin_open(_src, 0); // copy source
var dst = file_bin_open(_dst, 1); // destination
var size = file_bin_size(src);    // size of file
repeat (size) // copy each bytes
{
    file_bin_write_byte(dst, file_bin_read_byte(src));
}
file_bin_close(dst);
file_bin_close(src);
}

#region // import file

/// file_bin_import_file(fileid, srcfile);
// import variable size file to already opened file id

function file_bin_import_file(_f, _src)
{
	var f = _f;                            // import destination
	var src = file_bin_open(_src, 0);        // source file
	var size = file_bin_size(src);                // size of source file
	file_bin_write_variable_unsigned(f,size); // write size first (variable size unsigned format)
	repeat (size)                             // copy each bytes
	{
		file_bin_write_byte(f, file_bin_read_byte(src));
	}
	file_bin_close(src);
}

/// file_bin_import_file_rle(fileid, srcfile);
// RLE compress and import variable size file to already opened file id

function file_bin_import_file_rle(_f, _src)
{
	var f = _f;                       // import destination
	var src = file_bin_open(_src, 0); // source file
	var tmp = file_bin_open_temp("rle"); // temporary file used to RLE buffer
	var size = rle_compress_file(src, tmp);   // size of source file
	file_bin_write_variable_unsigned(f,size); // write size first (variable size unsigned format)
	file_bin_seek(tmp, 0);
	repeat (size) // copy each bytes
	{
		file_bin_write_byte(f, file_bin_read_byte(tmp));
	}
	file_bin_close_temp(tmp,"rle");
	file_bin_close(src);
}

/// file_bin_import_file_drle(fileid, srcfile);
// Delta RLE compress and import variable size file to already opened file id

function file_bin_import_file_drle(_f, _src)
{
	var f = _f;                       // import destination
	var src = file_bin_open(_src, 0); // source file
	var tmp = file_bin_open_temp("rle"); // temporary file used to RLE buffer
	var size = drle_compress_file(src, tmp);  // size of source file
	file_bin_write_variable_unsigned(f,size); // write size first (variable size unsigned format)
	file_bin_seek(tmp, 0);
	repeat (size) // copy each bytes
	{
		file_bin_write_byte(f, file_bin_read_byte(tmp));
	}
	file_bin_close_temp(tmp,"rle");
	file_bin_close(src);
}

/// file_bin_import_file_string(fileid, srcfile);
// import variable size file to already opened file id, with filename

function file_bin_import_file_string(_f, _src)
{
	var f = _f;                             // import destination
	var src = string(_src);                 // filename
	file_bin_write_variable_string(f, src); // write filename string
	file_bin_import_file(f, src);           // and import
}

/// file_bin_import_file_string_rle(fileid, srcfile);
// RLE compress and import variable size file to already opened file id, with filename

function file_bin_import_file_string_rle(_f, _src)
{
	var f = _f;                             // import destination
	var src = string(_src);                 // filename
	file_bin_write_variable_string(f, src); // write filename string
	file_bin_import_file_rle(f, src);       // and import
}

/// file_bin_import_file_string_drle(fileid, srcfile);
// Delta RLE compress and import variable size file to already opened file id, with filename
function file_bin_import_file_string_drle(_f, _src)
{
	var f = _f;                             // import destination
	var src = string(_src);                 // filename
	file_bin_write_variable_string(f, src); // write filename string
	file_bin_import_file_drle(f, src);      // and import
}

#endregion

#region // export file

/// file_bin_export_file(fileid, dstfile);
// export variable size file from already opened file id

function file_bin_export_file(_f,_dst)
{
	var f = _f;                                    // export source
	var dst = file_bin_open(_dst, 1);              // destination
	var size = file_bin_read_variable_unsigned(f); // size of file
	repeat (size) // copy each bytes
	{
		file_bin_write_byte(dst, file_bin_read_byte(f));
	}
	file_bin_close(dst);
}

/// file_bin_export_file_rle(fileid, dstfile);
// export and RLE decompress variable size file from already opened file id

function file_bin_export_file_rle(_f, _dst)
{
	var f = _f;                       // export source
	var dst = file_bin_open(_dst, 1); // destination
	var tmp = file_bin_open_temp("rle"); // temporary file used to RLE buffer
	var size = file_bin_read_variable_unsigned(f); // size of file
	repeat (size) // copy each bytes
	{
		file_bin_write_byte(tmp, file_bin_read_byte(f));
	}
	file_bin_seek(tmp, 0);
	rle_decompress_file(tmp, dst);
	file_bin_close_temp(tmp,"rle");
	file_bin_close(dst);
}

/// file_bin_export_file_drle(fileid, dstfile);
// export and Delta RLE decompress variable size file from already opened file id

function file_bin_export_file_drle(_f, _dst)
{
	var f = _f;                             // export source
	var dst = file_bin_open(_dst, 1);         // destination
	var tmp = file_bin_open_temp("rle"); // temporary file used to RLE buffer
	var size = file_bin_read_variable_unsigned(f); // size of file
	repeat (size) // copy each bytes
	{
		file_bin_write_byte(tmp, file_bin_read_byte(f));
	}
	file_bin_seek(tmp, 0);
	drle_decompress_file(tmp, dst);
	file_bin_close_temp(tmp,"rle");
	file_bin_close(dst);
}

/// file_bin_export_file_string(fileid);
// export variable size file from already opened file id, with filename

function file_bin_export_file_string(_f)
{
	var f = _f;                                 // export source
	var dst = file_bin_read_variable_string(f); // get filename to export
	file_bin_export_file(f, dst);               // and export
}

/// file_bin_export_file_string_rle(fileid);
// export and RLE decompress variable size file from already opened file id, with filename

function file_bin_export_file_string_rle(_f)
{
	var f = _f;                                 // export source
	var dst = file_bin_read_variable_string(f); // get filename to export
	file_bin_export_file_rle(f, dst);           // and export
}

/// file_bin_export_file_string_drle(fileid);
// export and Delta RLE decompress variable size file from already opened file id, with filename

function file_bin_export_file_string_drle(_f)
{
	var f = _f;                                 // export source
	var dst = file_bin_read_variable_string(f); // get filename to export
	file_bin_export_file_drle(f, dst);          // and export
}

#endregion

#region // temporary buffer file handlers

/// file_bin_open_temp(prefix);
// open temporary buffer file, return id

function file_bin_open_temp(_prefix)
{
	var prefix = string(_prefix);
	var f = file_bin_open(temp_directory + "\_" + prefix + "_temp", 2); // open temporary file
	file_bin_rewrite(f); // clear before use it
	return f;
}

/// file_bin_close_temp(fileid, prefix);
// close temporary buffer file

function file_bin_close_temp(_f, _prefix)
{
	var f = _f;
	var prefix = string(_prefix);
	file_bin_rewrite(f); // clear before close for some protection purpose
	file_bin_close(f);
	file_delete(temp_directory + "\_" + prefix + "_temp"); // delete closed buffer, also for some protection purpose
}

#endregion

#endregion

#region // RLE handlers

#region // RLE compress file

/// rle_compress_file(srcfile, destfile);
// RLE compress srcfile data and write result to destfile
// return size

function rle_compress_file(_fin, _fout)
{
	var fin = _fin;
	var fout = _fout;
	var curr = 0;
	var prev = -1;
	var repval = 0;
	var ret = 0;

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
}

/// drle_compress_file(srcfile, destfile);
// Delta RLE compress srcfile data and write result to destfile
// return size

function drle_compress_file(_fin, _fout)
{
	var fin = _fin;
	var fout = _fout;
	var curr = 0;
	var prev = -1;
	var dcur = 0;
	var dprv = 0;
	var repval = 0;
	var ret = 0;

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
}

#endregion

#region // Decompress RLE compressed file

/// rle_decompress_file(srcfile, destfile);
// decompress RLE compressed srcfile data and write result to destfile
// return size

function rle_decompress_file(_fin, _fout)
{
	var fin = _fin;
	var fout = _fout;
	var curr = 0;
	var prev = -1;
	var repval = 0;
	var ret = 0;

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
}

/// drle_decompress_file(srcfile, destfile);
// decompress Delta RLE compressed srcfile data and write result to destfile
// return size

function drle_decompress_file(_fin, _fout)
{
	var fin = _fin;
	var fout = _fout;
	var dbuf = 0;
	var curr = 0;
	var prev = -1;
	var repval = 0;
	var ret = 0;

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
}

#endregion

#endregion