/* nr_net_probe.c — the library, asked for the frame the Python asked for.
 *
 * The plan's own file carries the state the network was recorded from, including the
 * features: what the Python put in the graph's way in. `dump_plan.py` writes those on
 * their own as well, and this puts them back through the library's front door —
 * `nr_net_features`, then `nr_net_run` — and asks for the head.
 *
 * The answer has to be the Python's, bit for bit. If it is, then the library is not
 * merely replaying: it is running a frame a caller filled in, which is the thing the
 * bridge needs and the one the standalone replayer does not show.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "nr_net.h"

static unsigned char *slurp(const char *path, unsigned long long *size)
{
	FILE *in = fopen(path, "rb");
	if (!in)
		return NULL;
	fseek(in, 0, SEEK_END);
	*size = (unsigned long long)ftell(in);
	fseek(in, 0, SEEK_SET);
	unsigned char *bytes = malloc((size_t)*size);
	if (!bytes || fread(bytes, 1, (size_t)*size, in) != *size) {
		fclose(in);
		return NULL;
	}
	fclose(in);
	return bytes;
}

int main(int argc, char **argv)
{
	const char *folder = argc > 1 ? argv[1]
		: "E:\\WorkBuddy\\2026-10-09-04-20-55\\src\\dlss-nr-on-a770\\work";

	char library[1024], features[1024];
	snprintf(library, sizeof library, "%s\\libxmx.dll", folder);
	snprintf(features, sizeof features, "%s\\plan_960x544_in.bin", folder);

	unsigned long long have = 0;
	unsigned char *input = slurp(features, &have);
	if (!input) {
		fprintf(stderr, "cannot read %s — run tools/dump_plan.py first\n", features);
		return 1;
	}

	nr_net *net = nr_net_open(library, folder, NULL);
	if (!net || nr_net_error(net)) {
		fprintf(stderr, "open: %s\n", nr_net_error(net) ? nr_net_error(net) : "?");
		return 1;
	}

	unsigned height = 0, width = 0;
	nr_net_extent(net, &height, &width);
	printf("extent %ux%u  features %llu B  head %llu B\n", width, height,
	       nr_net_features_bytes(net), nr_net_head_bytes(net));

	if (have != nr_net_features_bytes(net)) {
		fprintf(stderr, "the recorded input is %llu B, the network wants %llu B\n",
			have, nr_net_features_bytes(net));
		return 1;
	}

	/* The frame the Python ran, put in the way a caller puts its own in. */
	memcpy(nr_net_features(net), input, (size_t)have);

	if (nr_net_run(net) != 0) {
		fprintf(stderr, "run: %s\n", nr_net_error(net) ? nr_net_error(net) : "?");
		return 1;
	}

	const float *head = nr_net_head(net);
	printf("head: %.8f %.8f %.8f %.8f\n", head[0], head[1], head[2], head[3]);

	/* The same frame again, to see the cost of one that is not the first. */
	for (int i = 0; i < 3; i++) {
		if (nr_net_run(net) != 0)
			return 1;
	}
	printf("again: %.8f %.8f %.8f %.8f\n", head[0], head[1], head[2], head[3]);

	nr_net_close(net);
	free(input);
	return 0;
}
