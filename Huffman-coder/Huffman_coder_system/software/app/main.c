//main.c
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

#include "io.h"
#include "alt_types.h"
#include "system.h"

#define ASCII_NORMALIZATION 65

static bool finalized = false; // set to 1 when we are sure that there is nothing left for read.

static int coder_write(uint8_t addr) {
  // TODO: check if full.

  IOWR_32DIRECT(HUFFMAN_CODER_IP_0_BASE, 0, addr);
  finalized = false;
  return 0;
}

static void coder_read(uint32_t *encoded_output, uint8_t *encoded_length) {

  if (finalized == true) {
    *encoded_length = 0;
    return;
  }

  if (IORD(PIO_EMPTY_BASE, 0)) { // is fifo empty?

    IOWR(PIO_DATA_LENGTH_BASE, 0, 1);
    *encoded_length = IORD_32DIRECT(HUFFMAN_CODER_IP_0_BASE, 0);
    IOWR(PIO_DATA_LENGTH_BASE, 0, 0);

    printf("DEBUG: encoded_length = %d\n", *encoded_length);
    if (*encoded_length > 0) { // is anything to get with finalize?
      // finalize
      IOWR(PIO_FINALIZE_BASE, 0, 1);
      *encoded_output = IORD_32DIRECT(HUFFMAN_CODER_IP_0_BASE, 0);
      IOWR(PIO_FINALIZE_BASE, 0, 0);
    }

    // there is nothing more to read.
    finalized = true;

  } else {
    // fifo has data. Read it.
    *encoded_output = IORD_32DIRECT(HUFFMAN_CODER_IP_0_BASE, 0);
    *encoded_length = 32;
  }
}

void encode(const char *string_to_encode) {
  uint8_t i, normalized_ascii;

  int strLength = strlen(string_to_encode);

  for (i = 0; i < strLength; i++) {
      normalized_ascii = (string_to_encode[i] - (ASCII_NORMALIZATION));
      printf("Write to coder: encode %d (normalized ascii for %c)\n", normalized_ascii, string_to_encode[i]);
      coder_write(normalized_ascii);
  }
}

void print_encoded() {
  uint8_t length = 0;
  int j;
  uint32_t bit;
  uint32_t enc_data = 0;
  printf("Encoded data:\n");

  coder_read(&enc_data, &length);
  while (length > 0) {
    for (j = (length - 1); j >= 0; --j) {
      bit = (enc_data >> j);

      if (bit & 1)
        printf("1");
      else
        printf("0");
    }
    coder_read(&enc_data, &length);
  }
  printf("\nEnd of encoded data.\n");
}

const char *sample = "ToMusiBycZakodowane";
const char *sample2 = "abc";

int main() {
  printf("HELLO FROM NIOS II PROCESSOR PROGRAM\n");

  while(1) {

    encode(sample);
    print_encoded();

    // for (i = 0; i < 63; ++i) {
    //   coder_write(i);
    // }

    // for (i = 0; i < 10; ++i) {
    //   printf("Read\n");
    //   val = IORD_32DIRECT(HUFFMAN_CODER_IP_0_BASE, 0);
    //   printf("val(hex): %x\n", val);
    // }

    // printf("Test span, three zero one \n");
    // IOWR(HUFFMAN_CODER_IP_0_BASE + 3, 0, 1);

    // printf("Test finalize PIO - set to one\n");
    // IOWR(PIO_FINALIZE_BASE, 0, 1);

    // printf("(PIO) Code letter a, ascii (%d)\n", ((int)'a' - 97));
    // val = IORD_32DIRECT(HUFFMAN_CODER_IP_0_BASE, 0);
    // printf("val(hex): %x\n", val);

    // printf("Test finalize PIO - set back to zero\n");
    // IOWR(PIO_FINALIZE_BASE, 0, 0);

    // printf("Code letter f, ascii (%d)\n", ((int)'f' - 97));
    // val = IORD_32DIRECT(HUFFMAN_CODER_IP_0_BASE, 1);
    // printf("val(hex): %x\n", val);

    // printf("Code letter unknown\n");
    // val = IORD_32DIRECT(HUFFMAN_CODER_IP_0_BASE + 1, 0);
    // printf("val(hex): %x\n", val);
  }
}
