#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define CALC_SIZE	256 - 32
char input_calc[CALC_SIZE];
char check_calc[CALC_SIZE];

void calc_word(char *word, char *calc) {
	memset(calc, 0, CALC_SIZE);

	do {

		if (*word > 32) {
			calc[*word - 32]++;
		}
	} while (*(++word));
}

int main(int argc, char *argv[]) {
	char buf[128];
	FILE *fp;
	int i;

	if (argc < 2) {
		fprintf(stderr, "Missing argument\n");
		return EXIT_FAILURE;
	}

	printf("Input word: %s\n", argv[1]);
	calc_word(argv[1], input_calc);

	fp = fopen("ordalisti.txt", "r");
	if (fp == NULL) {
		fprintf(stderr, "Unable to open ordalisti.txt\n");
		return EXIT_FAILURE;
	}

	i = 0;
	while (fgets(buf, sizeof(buf), fp) > 0) {
		printf("\rWords checked: %d", i++);
		calc_word(buf, check_calc);

		if (!memcmp(input_calc, check_calc, CALC_SIZE)) {
			printf("\r                 \rFound match: %s", buf);
			return EXIT_SUCCESS;
		}
	}

	printf("\nNo match found\n");
	return EXIT_FAILURE;
}


