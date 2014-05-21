#include "../spec.h"
#include <stdio.h>
#include <string.h>
#include <vector>

void read_hex_bits(std::vector<bool> &bits, const char *p)
{
	bits.clear();
	bits.resize(4*strlen(p));
	for (int i = int(bits.size())-1; i >= 0; p++) {
		int v = 'a' <= *p && *p <= 'f' ? *p - 'a' + 10 :
		        'A' <= *p && *p <= 'F' ? *p - 'A' + 10 : *p - '0';
		bits[i--] = (v & 8) != 0;
		bits[i--] = (v & 4) != 0;
		bits[i--] = (v & 2) != 0;
		bits[i--] = (v & 1) != 0;
	}
}

static inline void setbit(CData &data, int idx, bool v) { if (v) data |= CData(1) << idx; else data &= ~(CData(1) << idx); }
static inline void setbit(SData &data, int idx, bool v) { if (v) data |= SData(1) << idx; else data &= ~(SData(1) << idx); }
static inline void setbit(IData &data, int idx, bool v) { if (v) data |= IData(1) << idx; else data &= ~(IData(1) << idx); }
static inline void setbit(QData &data, int idx, bool v) { if (v) data |= QData(1) << idx; else data &= ~(QData(1) << idx); }
static inline void setbit(WData *data, int idx, bool v) { if (v) data[idx/32] |= WData(1) << (idx % 32); else data[idx/32] &= ~(WData(1) << (idx%32)); }

static inline bool getbit(const CData &data, int idx) { return (data & (CData(1) << idx)) != 0; }
static inline bool getbit(const SData &data, int idx) { return (data & (SData(1) << idx)) != 0; }
static inline bool getbit(const IData &data, int idx) { return (data & (IData(1) << idx)) != 0; }
static inline bool getbit(const QData &data, int idx) { return (data & (QData(1) << idx)) != 0; }
static inline bool getbit(const WData *data, int idx) { return (data[idx/32] & (WData(1) << (idx % 32))) != 0; }

#define SET(_port, _msb, _lsb) do { for (int i = 0; i <= (_msb)-(_lsb); i++) setbit(_port, i, input_bits.at((_lsb) + i)); } while (0)

int main()
{
	spec_module_name uut;
	int lines = 0, errors = 0;
	FILE *f = fopen("refdat.txt", "r");
	char buffer[1024];

	while (fgets(buffer, 1024, f) != NULL)
	{
		lines++;

		std::vector<bool> input_bits, output_bits, output_dc;
		read_hex_bits(input_bits, strtok(buffer, " \t\r\n"));
		read_hex_bits(output_bits, strtok(NULL, " \t\r\n"));
		read_hex_bits(output_dc, strtok(NULL, " \t\r\n"));

		spec_module_args
		uut.eval();

		for (int i = 0; i < spec_output_bits; i++)
			if (!output_dc.at(i) && output_bits.at(i) != getbit(uut.y, i)) {
				printf("ERROR in pattern #%d (bit %d): expected %c but got %c.\n", lines, i,
						output_bits.at(i) ? '1' : '0', getbit(uut.y, i) ? '1' : '0');
				errors++;
			}
	}

	uut.final();

	if (errors != 0)
		printf("++ERROR++ At least one fail pattern found.\n");
	if (lines != 1000)
		printf("++ERROR++ Incorrect number of records read from refdat.txt.\n");
	if (errors == 0 && lines == 1000)
		printf("++OK++\n");

	return 0;
}

