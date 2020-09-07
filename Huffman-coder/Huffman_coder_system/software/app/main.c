//main.c
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

#include "io.h"
#include "alt_types.h"
#include "system.h"

#define ASCII_NORMALIZATION 65

static bool finalized = false; // set to 1 when we are sure that there is nothing left for read.

static void coder_write_tree(const uint8_t addr, const uint8_t code, const uint8_t codelen) {
  if (codelen > 8) {return;}
  if (addr > 63) {return;}

  uint16_t code_value = (codelen | (code << 4)); // 12 bits is stored in LUT: 4 last bits is for code length.
  uint32_t value = (addr | (code_value << 6));
  IOWR(PIO_ACCESS_MODE_BASE, 0, 1);
  IOWR(HUFFMAN_CODER_IP_0_BASE, 0, value);
  IOWR(PIO_ACCESS_MODE_BASE, 0, 0);
}

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

    IOWR(PIO_ACCESS_MODE_BASE, 0, 1);
    *encoded_length = IORD_32DIRECT(HUFFMAN_CODER_IP_0_BASE, 0);
    IOWR(PIO_ACCESS_MODE_BASE, 0, 0);

    // printf("DEBUG: encoded_length = %d\n", *encoded_length);
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

  coder_write_tree(('T' - ASCII_NORMALIZATION), 0x2, 3);  // 010
  coder_write_tree(('o' - ASCII_NORMALIZATION), 0x1, 3);  // 001
  coder_write_tree(('M' - ASCII_NORMALIZATION), 0x1a, 5); // 11010
  coder_write_tree(('u' - ASCII_NORMALIZATION), 0xe, 3);  // 11110
  coder_write_tree(('s' - ASCII_NORMALIZATION), 0xa, 4);  // 1010
  coder_write_tree(('i' - ASCII_NORMALIZATION), 0x7, 4);  // 0111
  coder_write_tree(('B' - ASCII_NORMALIZATION), 0xf, 3);  // 111
  coder_write_tree(('y' - ASCII_NORMALIZATION), 0x6, 4);  // 0110
  coder_write_tree(('c' - ASCII_NORMALIZATION), 0xf, 3);  // 111
  coder_write_tree(('Z' - ASCII_NORMALIZATION), 0x1b, 5); // 11011
  coder_write_tree(('a' - ASCII_NORMALIZATION), 0x0f, 5); // 01111
  coder_write_tree(('k' - ASCII_NORMALIZATION), 0x10, 5); // 10000
  coder_write_tree(('d' - ASCII_NORMALIZATION), 0x1c, 5); // 11100
  coder_write_tree(('w' - ASCII_NORMALIZATION), 0x3b, 6); // 111011
  coder_write_tree(('n' - ASCII_NORMALIZATION), 0x11, 5); // 10001
  coder_write_tree(('e' - ASCII_NORMALIZATION), 0x12, 5); // 10010

  // final length = 79

  while(1) {
    encode(sample);
    print_encoded();
  }
}
