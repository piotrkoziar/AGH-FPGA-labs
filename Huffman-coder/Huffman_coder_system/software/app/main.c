//main.c
#include "io.h"
#include "alt_types.h"
#include "system.h"

// #define PI_VAL  3.14
// #define FXP_MUL 1024

/** Simple program that gets elipse coordinations and exports it.
 */

char *sample = "ToMusiBycZakodowane";

int main() {
  printf("HELLO FROM NIOS II PROCESSOR PROGRAM\n");

  // const alt_u32 angle_last  = PI_VAL * 2 * FXP_MUL;
  // const alt_u32 angle_first = 0;

  // // Get start angle value.
  // alt_u32 angle_start  = IORD_32DIRECT(ANGLE_IN_BASE, 0); //<- Start angle.
  // alt_u32 angle_cordic = angle_start;

  // /** Coordinates (x, y) are equal to (a * cos(alfa), b * sin(alfa)).
  //  * Cordic processor is used to calculate cos(alfa) and sin(alfa).
  //  */
  // alt_32 elipse_a = 0x0000; //<- Elipse parameter a.
  // alt_32 elipse_b = 0x0000; //<- Elipse parameter b.

  // alt_32 sincos, sin, cos;

  // alt_32 coord_x, coord_y;

  unsigned int val = 0;
  while(1) {
    printf("Code letter a, ascii (%d)\n", ((int)'a' - 97));
    val = IORD_32DIRECT(HUFFMAN_CODER_IP_0_BASE, 0);
    printf("%x\n", val);
    printf("Code letter f, ascii (%d)\n", ((int)'f' - 97));
    val = IORD_32DIRECT(HUFFMAN_CODER_IP_0_BASE + 1, 0);
    printf("%x\n", val);
    // // Get elipse parameters.
    // elipse_a = IORD_32DIRECT(ELIPSE_A_IN_BASE, 0);
    // elipse_b = IORD_32DIRECT(ELIPSE_B_IN_BASE, 0);

    // if (angle_cordic > angle_last) {
    //   angle_cordic = angle_first;
    // }

    // IOWR(CORDIC_PIPELINE_AVALON_INTERFACE_0_BASE, 0, (angle_cordic)); // Write the angle to cordic processor.

    // sincos = IORD_32DIRECT(CORDIC_PIPELINE_AVALON_INTERFACE_0_BASE, 0);
    // sin = sincos         & 0xfff; // bits 0-11
    // cos = (sincos >> 16) & 0xfff; // bits 16-27

    // // Extend MSB (to get proper signed value)
    // sin = (sin & (0x1 << 11)) ?
    //       sin | (0xFFFFF << 12 ) :
    //       sin;

    // cos = (cos & (0x1 << 11)) ?
    //       cos | (0xFFFFF << 12 ) :
    //       cos;

    // coord_x = elipse_a * cos;
    // coord_y = elipse_b * sin;

    // IOWR(ELIPSE_X_OUT_BASE, 0, (coord_x)); // Export x coordinate.
    // IOWR(ELIPSE_Y_OUT_BASE, 0, (coord_y)); // Export y coordinate.

    // angle_cordic += 64;
  }
}
