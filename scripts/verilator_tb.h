#ifndef VERILATOR_TB_H
#define VERILATOR_TB_H

#include <set>
#include <vector>
#include <string>
#include <stdio.h>
#include <stdlib.h>

#define PATTERN_BITS_N 4096

Vtestbench tb;
bool pattern_bits[PATTERN_BITS_N];
int pattern_cursor, pattern_idx;

std::string input_pat_list;
std::vector<string> input_patterns_buf;
std::set<int> undef_bits;

static inline void set_pattern(const char *pattern)
{
	bool val0 = false, val1 = true;

	pattern_cursor = 0;

	if (*pattern == '~') {
		val0 = true;
		val1 = false;
		pattern++;
	}

	while ('0' <= *pattern && *pattern <= '9')
		pattern++;

	if (*pattern == '\'')
		pattern++;

	if (*pattern == 'b')
	{
		int pattern_len = strlen(++pattern);
		for (int i = pattern_len - 1; i >= 0; i--)
			pattern_bits[pattern_cursor++] = (pattern[i] == '1') ? val1 : val0;
	}
	else
	if (*pattern == 'h')
	{
		int pattern_len = strlen(++pattern);
		for (int i = pattern_len - 1; i >= 0; i--) {
			char ch = pattern[i];
			if ('a' <= ch && ch <= 'f')
				ch = ch - 'a' + 10;
			else if ('A' <= ch && ch <= 'F')
				ch = ch - 'A' + 10;
			else
				ch = ch - '0';
			pattern_bits[pattern_cursor++] = (ch & 1) ? val1 : val0;
			pattern_bits[pattern_cursor++] = (ch & 2) ? val1 : val0;
			pattern_bits[pattern_cursor++] = (ch & 4) ? val1 : val0;
			pattern_bits[pattern_cursor++] = (ch & 8) ? val1 : val0;
		}
	}
	else
		abort();

	while (pattern_cursor < PATTERN_BITS_N)
		pattern_bits[pattern_cursor++] = val0;

	pattern_cursor = 0;
	input_pat_list.clear();
	input_patterns_buf.clear();
	undef_bits.clear();
}

static inline void print_input_patterns()
{
	for (int i = int(input_patterns_buf.size())-1; i >= 0; i--)
		printf("%s", input_patterns_buf[i].c_str());
}

static inline void set_input(const char *name, int bits)
{
	std::string patbuf;
	char buffer[1024];
	int cursor = 0;

	cursor += snprintf(buffer+cursor, 1024-cursor, "++PAT++ %d %s ", pattern_idx, name);
	for (int i = bits-1; i >= 0; i--) {
		cursor += snprintf(buffer+cursor, 1024-cursor, "%d", int(pattern_bits[pattern_cursor+i]));
		patbuf += pattern_bits[pattern_cursor+i] ? "1" : "0";
	}
	cursor += snprintf(buffer+cursor, 1024-cursor, " #\n");
	input_patterns_buf.push_back(buffer);

	input_pat_list = patbuf + (input_pat_list.empty() ? "" : " ") + input_pat_list;
}

static inline void set_input8(const char *name, CData &data, int bits)
{
	set_input(name, bits);
	data = 0;
	for (int i = 0; i < bits; i++)
		if (pattern_bits[pattern_cursor++])
			data |= CData(1) << i;
}

static inline void set_input16(const char *name, SData &data, int bits)
{
	set_input(name, bits);
	data = 0;
	for (int i = 0; i < bits; i++)
		if (pattern_bits[pattern_cursor++])
			data |= SData(1) << i;
}

static inline void set_input32(const char *name, IData &data, int bits)
{
	set_input(name, bits);
	data = 0;
	for (int i = 0; i < bits; i++)
		if (pattern_bits[pattern_cursor++])
			data |= IData(1) << i;
}

static inline void set_input64(const char *name, QData &data, int bits)
{
	set_input(name, bits);
	data = 0;
	for (int i = 0; i < bits; i++)
		if (pattern_bits[pattern_cursor++])
			data |= QData(1) << i;
}

static inline void set_inputW(const char *name, WData data[], int bits)
{
	set_input(name, bits);
	for (int i = 0; i < (bits+31) / 32; i++)
		data[i] = 0;
	for (int i = 0; i < bits; i++)
		if (pattern_bits[pattern_cursor++])
			data[i/32] |= WData(1) << (i % 32);
}

static inline void set_undef(const char *pattern)
{
	int pattern_len = strlen(pattern);
	for (int i = 0; i < pattern_len; i++)
		if (pattern[pattern_len-1-i] == 'x' || pattern[pattern_len-1-i] == 'X')
			undef_bits.insert(i);
}

static inline void get_output(const char *name, std::vector<bool> &vec)
{
	std::string result;
	for (int i = int(vec.size())-1; i >= 0; i--)
		result += undef_bits.count(i) ? "x" : vec[i] ? "1" : "0";
	printf("++VAL++ %d %s %s #\n", pattern_idx, name, result.c_str());
	printf("++RPT++ %d %s %s %s\n", pattern_idx, input_pat_list.c_str(), result.c_str(), name);
}

static inline void get_output8(const char *name, CData &data, int bits)
{
	std::vector<bool> vec;
	for (int i = 0; i < bits; i++)
		vec.push_back((data & (CData(1) << i)) != 0);
	get_output(name, vec);
}

static inline void get_output16(const char *name, SData &data, int bits)
{
	std::vector<bool> vec;
	for (int i = 0; i < bits; i++)
		vec.push_back((data & (SData(1) << i)) != 0);
	get_output(name, vec);
}

static inline void get_output32(const char *name, IData &data, int bits)
{
	std::vector<bool> vec;
	for (int i = 0; i < bits; i++)
		vec.push_back((data & (IData(1) << i)) != 0);
	get_output(name, vec);
}

static inline void get_output64(const char *name, QData &data, int bits)
{
	std::vector<bool> vec;
	for (int i = 0; i < bits; i++)
		vec.push_back((data & (QData(1) << i)) != 0);
	get_output(name, vec);
}

static inline void get_outputW(const char *name, WData data[], int bits)
{
	std::vector<bool> vec;
	for (int i = 0; i < bits; i++)
		vec.push_back((data[i/32] & (WData(1) << (i % 32))) != 0);
	get_output(name, vec);
}

#endif
