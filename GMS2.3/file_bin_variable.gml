#region // write variable size integer

/// file_bin_write_variable_unsigned(file, variable);
// write variable size unsigned value to file (little endian)

function file_bin_write_variable_unsigned(f, in)
{
	if (in < $80) // 0-7f : Single byte
	{
		file_bin_write_byte(f,in);
	}
	else          // larger: Multi byte
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
}


/// file_bin_write_variable_signed(file, variable);
// write variable size signed value to file (little endian)
// bit 6 of first byte is sign bit

function file_bin_write_variable_signed(f, in)
{
	var flag = 0; // sign bit
	if (in < 0)   // input is negative?
	{
		in = -(in + 1);
		flag = $40;
	}
	// convert to unsigned
	in = (in & $3f) | ((in & ~$3f) << 1) | flag;
	file_bin_write_variable_unsigned(f,in);
}

#endregion

#region // write variable size real

/// file_bin_write_variable_fraction(file, variable);
// write variable size fraction value to file

function file_bin_write_variable_fraction(f, in)
{
	in = frac(in); // fraction only
	var out = 0;   // output value
	var bpos = 0;  // bit position
	var pos = 1;   // fraction position
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
}

/// file_bin_write_variable_unsigned_frac(file, variable);
// write variable size unsigned value to file (little endian, with fraction)
// bit 6 of first byte is fraction bit

function file_bin_write_variable_unsigned_frac(f, in)
{
	var flag = 0;           // fraction bit
	var fracval = frac(in); // fraction value
	if (fracval > 0)        // fraction value is larger than 0?
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
}

/// file_bin_write_variable_signed_frac(file, variable);
// write variable size signed value to file (little endian, with fraction)
// bit 6 of first byte is sign bit
// bit 5 of first byte is fraction bit

function file_bin_write_variable_signed_frac(f, in)
{
	var flag = 0; // sign and fraction bit
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
	file_bin_write_variable_unsigned(f,in);
	if (flag & $20)
	{
		file_bin_write_variable_fraction(f,fracval);
	}
}

#endregion

#region // read variable size integer

/// file_bin_read_variable_unsigned(file);
// read variable size unsigned value from file (little endian)

function file_bin_read_variable_unsigned(f)
{
	var in = file_bin_read_byte(f); // data from file
	if (in & $80)                   // multi-byte flag?
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
}

/// file_bin_read_variable_signed(file);
// read variable size signed value from file (little endian)
// bit 6 of first byte is sign bit

function file_bin_read_variable_signed(f)
{
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

function file_bin_read_variable_fraction(f)
{
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

function file_bin_read_variable_unsigned_frac(f)
{
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

function file_bin_read_variable_signed_frac(f)
{
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

#region // variable size hexadecimal or decimal string

/// file_bin_read_variable_hexstring(file, [lower]);
// read variable size hexadecimal or decimal format string from file

function file_bin_read_variable_hexstring(f, low)
{
	var in = file_bin_read_byte(f);  // input data from file
	var siz = 7;                     // data size
	var str = "";                    // output string
	var hexval = "0123456789ABCDEF"; // hexadecimal table for convert
	if (!is_undefined(low))          // optional lower case flag
	{
		if (low)
		{
			hexval = string_lower(hexval);
		}
	}
	if (in & $80)                    // multibyte data?
	{
		var hexin;
		hexin = in & $7f;            // input data
		siz = 7;                     // 7 bit
		while (in & $80)             // get hexadecimal and convert
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
		while (siz >= 4)             // flush remains
		{
			str = string_char_at(hexval, (hexin & $f) + 1) + str;
			hexin = hexin >> 4;
			siz -= 4;
		}
	}
	else
	{
		while (siz >= 4)             // get hexadecimal and convert
		{
			str = string_char_at(hexval, (in & $f) + 1) + str;
			in = in >> 4;
			siz -= 4;
		}
	}
	return str;
}

/// file_bin_write_variable_hexstring(file, hexstring);
// write variable size hexadecimal or decimal format string to file

function file_bin_write_variable_hexstring(f,str)
{
	str = string_upper(str);          // hexadecimal to file
	if (str == "")                    // empty?
	{
		file_bin_write_byte(f,0);
	}
	else
	{
		var hxv = "0123456789ABCDEF"; // hexadecimal table for convert
		var siz = 0;                  // data size
		var out = 0;                  // output value
		while (str != "")             // convert to integer and write
		{
			var tmp = (string_pos(string_char_at(str, string_length(str)), hxv) - 1);
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
}

#endregion

#region // variable size base64

/// file_bin_read_variable_base64(file, [padding]);
// read variable size base64 format string from file

function file_bin_read_variable_base64(f, padding)
{
	var in = file_bin_read_byte(f);                                                // input data from file
	var siz = 8;                                                                   // data size
	var str = "";                                                                  // output string
	var b64val = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"; // base64 table for convert
	if (in & $80)                                                                  // multibyte data?
	{
		var b64in = in & $7f;                                                      // input data
		siz = 7;                                                                   // 7 bit
		while (in & $80)                                                           // get base64 and convert
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
	if (!is_undefined(padding))               // optional padding flag
	{
		if (padding)
		{
			while (string_length(str) & 3)
			{
				str += "=";
			}
		}
	}
	return str;
}

/// file_bin_write_variable_base64(file, base64);
// write variable size base64 format string to file

function file_bin_write_variable_base64(f,str)
{
	str = string(str);                                                                // base64 to file
	if (str == "")                                                                    // empty?
	{
		file_bin_write_byte(f,0);
	}
	else
	{
		var b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"; // base64 table for convert
		var siz = 0;                                                                  // data size
		var out = 0;                                                                  // output value
		while (str != "")                                                             // convert to integer and write
		{
			var tst = string_char_at(str, string_length(str));
			if (tst != "=")                                                           // padding
			{
				var tmp = (string_pos(tst, b64) - 1);
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
}

#endregion

#region // variable size string

/// file_bin_read_variable_string(file);
// read variable size string from file

function file_bin_read_variable_string(f)
{
	var in = file_bin_read_variable_unsigned(f);                 // get length
	var res = "";                                                // string output
	repeat (in)                                                  // read string
	{
		res = chr(file_bin_read_variable_unsigned(f) + 1) + res; // get each character, +1 because $00 is end of string flag
	}
	return res;                                                  // output
}

/// file_bin_write_variable_string(file, string);
// write variable size string to file

function file_bin_write_variable_string(f, str)
{
	str = string(str);                                          // string for write
	file_bin_write_variable_unsigned(f, string_length(str));    // write length first
	while (str != "")                                           // write string
	{
		var tmp = ord(string_char_at(str, string_length(str))); // get each character
		file_bin_write_variable_unsigned(f,tmp - 1);            // write, -1 because $00 is end of string flag
		str = string_copy(str, 1, string_length(str) - 1);      // flush last
	}
}

#endregion

#region // import file

/// file_bin_import_file(fileid, srcfile);
// import variable size file to already opened file id
function file_bin_import_file(f, src)
{
	src = file_bin_open(string(src), 0);      // source file
	var size = file_bin_size(src);            // size of source file
	file_bin_write_variable_unsigned(f,size); // write size first (variable size unsigned format)
	repeat (size)                             // copy each bytes
	{
		file_bin_write_byte(f, file_bin_read_byte(src));
	}
	file_bin_close(src);
}

/// file_bin_import_file_string(fileid, srcfile);
// import variable size file to already opened file id, with filename
function file_bin_import_file_string(f, src)
{
	src = string(src);                      // filename
	file_bin_write_variable_string(f, src); // write filename string
	file_bin_import_file(f, src);           // and import
}

#endregion

#region // export file

/// file_bin_export_file(fileid, dstfile);
// export variable size file from already opened file id

function file_bin_export_file(f,dst)
{
	dst = file_bin_open(dst, 1);                   // destination
	var size = file_bin_read_variable_unsigned(f); // size of file
	repeat (size)                                  // copy each bytes
	{
		file_bin_write_byte(dst, file_bin_read_byte(f));
	}
	file_bin_close(dst);
}

/// file_bin_export_file_string(fileid);
// export variable size file from already opened file id, with filename

function file_bin_export_file_string(f)
{
	var dst = file_bin_read_variable_string(f); // get filename to export
	file_bin_export_file(f, dst);               // and export
}

#endregion