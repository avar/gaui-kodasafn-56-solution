#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>

long long get_ticks() {
    static struct timeval now;

    gettimeofday(&now, NULL);
    return((now.tv_sec * 1000) + (now.tv_usec / 1000));
}

char *str_rtrim(char *str) {
	int i;
	for (i = strlen(str) - 1; i >= 0; i--) {
		if (isspace(str[i])) {
			str[i] = '\0';
			continue;
		}
		break;
	}
	return str;
}

void bubblesort_word(char *word) {
	char *sort_outer, *sort_inner, save;

	for (sort_outer = word; *sort_outer; sort_outer++) {
		for (sort_inner = sort_outer + 1; *sort_inner; sort_inner++) {
			if (*sort_outer < *sort_inner) {
				continue;
			}
			save = *sort_outer;
			*sort_outer = *sort_inner;
			*sort_inner = save;
		}
	}
}

struct table {
	int					count;
	char				**ord;
	struct table		*table[256];
};

struct table word_table;

void table_insert(unsigned char *sorted_word, char *word) {
	struct table *table, *ntable;
	unsigned int index;
	unsigned char *s;

	s = sorted_word;
	table = &word_table;
	do {
		index = *s;
		ntable = table->table[index];
		if (ntable == NULL) {
			ntable = calloc(1, sizeof(struct table));
			table->table[index] = ntable;
		}
		table = ntable;
	} while (*(++s));


	table->ord = realloc(table->ord, sizeof(char *) * (table->count + 1));
	table->ord[table->count] = strdup(word);
	table->count++;
}

int table_search(unsigned char *word) {
	struct table *table;
	unsigned int index;

	table = &word_table;
	do {
		index = *word;
		table = table->table[index];
		if (table == NULL) {
			return 0;
		}
	} while (*(++word));

	printf("Matching words:\n");
	for (index = 0; index < table->count; index++) {
		printf("%2d %s\n", index, table->ord[index]);
	}

	return 1;
}

int main(int argc, char *argv[]) {
	char ord[128];
	char buf[128], sbuf[128];
	long long start, stop;
	FILE *fp;
	int len, i;

	memset(&word_table, 0, sizeof(word_table));
	if (argc < 2) {
		fprintf(stderr, "Missing argument\n");
		return EXIT_FAILURE;
	}

	strcpy(ord, argv[1]);
	bubblesort_word(ord);
	printf("Input word: %s, sorted: %s\n", argv[1], ord);

	fp = fopen("ordalisti.txt", "r");
	if (fp == NULL) {
		fprintf(stderr, "Unable to open ordalisti.txt\n");
		return EXIT_FAILURE;
	}

	i = 1;
	printf("Create word table\n");
	start = get_ticks();
	while (fgets(buf, sizeof(buf), fp) > 0) {
		str_rtrim(buf);
		strcpy(sbuf, buf);
		bubblesort_word(sbuf);
		table_insert(sbuf, buf);
	}
	stop = get_ticks();
	printf("Took %lld msec\n", (stop - start));

	start = get_ticks();
	i = table_search(ord);
	stop = get_ticks();
	printf("%lld msec\n", (stop - start));
	return i ? EXIT_SUCCESS : EXIT_FAILURE;
}

