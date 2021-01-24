///asr(source, shift, size);
// arithmetic shift right
function asr(src, am, size){
	src = (src & ((1 << size) - 1)); // mask source to size
	if (src & (1 << (size - 1))) // negative value?
	{
		if (size <= am) // if amount is larger or same than size
		{
			return ((1 << size) - 1);
		}
		return (src >> am) | (((1 << size) - 1) ^ ((1 << (size - am)) - 1));
	}
	// return positive value
	return src >> am;
}