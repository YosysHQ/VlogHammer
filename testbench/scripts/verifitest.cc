#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <set>

#include "veri_file.h"
#include "vhdl_file.h"
#include "VeriWrite.h"
#include "DataBase.h"
#include "Message.h"

#ifdef VERIFIC_NAMESPACE
using namespace Verific ;
#endif

void msg_func(msg_type_t msg_type, const char *message_id, linefile_type linefile, const char *msg, va_list args)
{
	printf("VERIFIC-%s [%s] ",
			msg_type == VERIFIC_NONE ? "NONE" :
			msg_type == VERIFIC_ERROR ? "ERROR" :
			msg_type == VERIFIC_WARNING ? "WARNING" :
			msg_type == VERIFIC_IGNORE ? "IGNORE" :
			msg_type == VERIFIC_INFO ? "INFO" :
			msg_type == VERIFIC_COMMENT ? "COMMENT" :
			msg_type == VERIFIC_PROGRAM_ERROR ? "PROGRAM_ERROR" : "UNKNOWN", message_id);
	if (linefile)
		printf("%s:%d: ", LineFile::GetFileName(linefile), LineFile::GetLineNo(linefile));
	vprintf(msg, args);
	printf("\n");
}

void dump_common(DesignObj *obj)
{
	MapIter mi;
	Att *attr;

	if (obj->Linefile())
		printf("    LINEFILE %s %d\n", LineFile::GetFileName(obj->Linefile()), LineFile::GetLineNo(obj->Linefile()));

	FOREACH_ATTRIBUTE(obj, mi, attr)
		printf("    ATTRIBUTE %s = %s\n", attr->Key(), attr->Value());
}

void dump_netlist(Netlist *nl)
{
	MapIter mi, mi2;

	printf("NETLIST: %s\n", nl->Owner()->Name());

	if (nl->IsPrimitive())
		printf("  IS_PRIMITIVE\n");

	if (nl->IsOperator())
		printf("  IS_OPERATOR\n");

	if (nl->IsConstant())
		printf("  IS_CONSTANT\n");

	if (nl->IsAssertion())
		printf("  IS_ASSERTATION\n");

	if (nl->IsCombinational())
		printf("  IS_COMBINATIONAL\n");

	if (nl->IsBlackBox())
		printf("  IS_BLACKBOX\n");

	Port *port;
	FOREACH_PORT_OF_NETLIST(nl, mi, port) {
		printf("  PORT: %s\n", port->Name());
		dump_common(port);
		if (port->Bus())
			printf("    BUS: %s %d\n", port->Bus()->Name(), port->Bus()->IndexOf(port));
		if (port->GetNet())
			printf("    NET: %s\n", port->GetNet()->Name());
		if (port->GetDir() == DIR_INOUT)
			printf("    INOUT\n");
		if (port->GetDir() == DIR_IN)
			printf("    INPUT\n");
		if (port->GetDir() == DIR_OUT)
			printf("    OUTPUT\n");
	}

	PortBus *portbus;
	FOREACH_PORTBUS_OF_NETLIST(nl, mi, portbus) {
		printf("  PORTBUS: %s [%d:%d]\n", portbus->Name(), portbus->LeftIndex(), portbus->RightIndex());
		dump_common(portbus);
		if (port->GetDir() == DIR_INOUT)
			printf("    INOUT\n");
		if (port->GetDir() == DIR_IN)
			printf("    INPUT\n");
		if (port->GetDir() == DIR_OUT)
			printf("    OUTPUT\n");
		for (int i = portbus->LeftIndex();; i += portbus->IsUp() ? +1 : -1) {
			printf("    %3d: %s\n", i, portbus->ElementAtIndex(i) ? portbus->ElementAtIndex(i)->Name() : "");
			if (i == portbus->RightIndex())
				break;
		}
	}

	Net *net;
	FOREACH_NET_OF_NETLIST(nl, mi, net) {
		printf("  NET: %s\n", net->Name());
		dump_common(net);
		if (net->Bus())
			printf("    BUS: %s %d\n", net->Bus()->Name(), net->Bus()->IndexOf(net));
		if (net->GetInitialValue())
			printf("    INIT: %c\n", net->GetInitialValue());
	}

	NetBus *netbus;
	FOREACH_NETBUS_OF_NETLIST(nl, mi, netbus) {
		printf("  NETBUS: %s [%d:%d]\n", netbus->Name(), netbus->LeftIndex(), netbus->RightIndex());
		dump_common(netbus);
		for (int i = netbus->LeftIndex();; i += netbus->IsUp() ? +1 : -1) {
			printf("    %3d: %s\n", i, netbus->ElementAtIndex(i) ? netbus->ElementAtIndex(i)->Name() : "");
			if (i == netbus->RightIndex())
				break;
		}
	}

	Instance *inst;
	FOREACH_INSTANCE_OF_NETLIST(nl, mi, inst) {
		PortRef *pr ;
		printf("  INSTANCE: %s %s\n", inst->View()->Owner()->Name(), inst->Name());
		if (inst->IsUserDeclared())
			printf("    IS_USER_DECLARED\n");
		dump_common(inst);
		FOREACH_PORTREF_OF_INST(inst, mi2, pr)
			printf("    PORTREF: %s %s\n", pr->GetPort()->Name(), pr->GetNet()->Name());
	}
}

int main(int argc, char **argv)
{
	int opt;
	const char *topmod = NULL;
	const char *outfile = NULL;

	while ((opt = getopt(argc, argv, "t:o:")) != -1)
	{
		switch (opt)
		{
		case 'o':
			outfile = optarg;
			break;
		case 't':
			topmod = optarg;
			break;
		default:
			goto help;
		}
	}

	if (optind == argc) {
help:
		fprintf(stderr, "Usage: %s [-t <top_module>] [-o <out_file>] <infiles>\n", argv[0]);
		return 1;
	}

	Message::SetConsoleOutput(0);
	Message::RegisterCallBackMsg(msg_func);

	vhdl_file vhdl_reader;
	veri_file veri_reader;
	VeriWrite veri_writer;

	bool got_vhdl = false;
	bool got_veri = false;

	for (; optind < argc; optind++)
		if (strlen(argv[optind]) > 4 && !strcmp(argv[optind]+strlen(argv[optind])-4, ".vhd")) {
			if (!got_vhdl)
				vhdl_reader.SetDefaultLibraryPath(VERIFIC_DIR "/vhdl_packages/vdbs");
			if (!vhdl_reader.Analyze(argv[optind])) {
				fprintf(stderr, "vhdl_reader.Analyze() failed for `%s'.\n", argv[optind]);
				return 1;
			}
			got_vhdl = true;
		} else {
			if (!veri_reader.Analyze(argv[optind])) {
				fprintf(stderr, "veri_reader.Analyze() failed for `%s'.\n", argv[optind]);
				return 1;
			}
			got_veri = true;
		}

	if (topmod == NULL)
	{
		if (got_vhdl && got_veri) {
			fprintf(stderr, "For mixed-langugage designs the -t option (specify top module) is mandatory.\n");
			return 1;
		}

		if (got_vhdl)
			if (!vhdl_reader.ElaborateAll()) {
				fprintf(stderr, "vhdl_reader.ElaborateAll() failed.\n");
				return 1;
			}

		if (got_veri)
			if (!veri_reader.ElaborateAll()) {
				fprintf(stderr, "veri_reader.ElaborateAll() failed.\n");
				return 1;
			}
	}
	else
	{
		if (veri_reader.GetModule(topmod))
		{
			if (!veri_reader.Elaborate(topmod)) {
				fprintf(stderr, "veri_reader.Elaborate(\"%s\") failed.\n", topmod);
				return 1;
			}
		}
		else
		{
			if (!vhdl_reader.Elaborate(topmod)) {
				fprintf(stderr, "vhdl_reader.Elaborate(\"%s\") failed.\n", topmod);
				return 1;
			}
		}
	}

	Netlist *top = Netlist::PresentDesign();
	if (!top) {
		fprintf(stderr, "Netlist::PresentDesign() failed.\n");
		return 1;
	}

	printf("INFO: Top-level module: %s\n", top->Owner()->Name());

	if (outfile != NULL) {
		veri_writer.WriteFile(outfile, top);
		return 0;
	}

	std::set<Netlist*> nl_todo, nl_done;
	nl_todo.insert(top);

	while (!nl_todo.empty())
	{
		Netlist *nl = *nl_todo.begin();
		dump_netlist(nl);

		nl_todo.erase(nl);
		nl_done.insert(nl);

		MapIter mi;
		Instance *inst;
		FOREACH_INSTANCE_OF_NETLIST(nl, mi, inst) {
			if (!nl_done.count(inst->View()))
				nl_todo.insert(inst->View());
		}
	}

	printf("INFO: Memory usage before reset: %lu\n", Libset::Global()->MemUsage());
	Libset::Reset();

	return 0;
}

