#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

int main(int argc, char *argv[]) {
	char ord[128];
	char buf[128];
	FILE *fp;
	int len, i;

	if (argc < 2) {
		fprintf(stderr, "Missing argument\n");
		return EXIT_FAILURE;
	}

	strcpy(ord, argv[1]);
	len = strlen(ord);
	bubblesort_word(ord);
	printf("Input word: %s, sorted: %s\n", argv[1], ord);

	fp = fopen("ordalisti.txt", "r");
	if (fp == NULL) {
		fprintf(stderr, "Unable to open ordalisti.txt\n");
		return EXIT_FAILURE;
	}

	i = 0;
	while (fgets(buf, sizeof(buf), fp) > 0) {
		printf("\rWords checked: %d", i++);
		str_rtrim(buf);
		bubblesort_word(buf);
		if (!strcmp(ord, buf)) {
			printf("\r                 \rFound match: %s\n", buf);
			return EXIT_SUCCESS;
		}
	}

	printf("\nNo match found\n");
	return EXIT_FAILURE;
}


