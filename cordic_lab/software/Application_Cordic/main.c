//main.c
#include "io.h"        //<- required for IOWR
#include "alt_types.h" //<- required for alt_u32
#include "system.h"    //<- contains address of CORDIC_PIPELINE_AVALON_INTERFACE_0_BASE

#define PI_VAL  3.14
#define FXP_MUL 1024

/** Simple program that gets elipse coordinations and exports it.
 */

int main() {
  printf("HELLO FROM NIOS II PROCESSOR PROGRAM\n");

  alt_32 angle_start  = 0x0000; //<- Start angle.
  alt_u32 elipse_a    = 0x0000; //<- Elipse parameter a.
  alt_u32 elipse_b    = 0x0000; //<- Elipse parameter b.

  // Get start angle value.
  angle_start = IORD_32DIRECT(ANGLE_IN_BASE, 0);

  /** Coordinates (x, y) are equal to (a * cos(alfa), b * sin(alfa)).
   * Cordic processor is used to calculate cos(alfa) and sin(alfa).
   */
  alt_32 coord_x, coord_y;

  const alt_32 angle_last  = PI_VAL * 2 * FXP_MUL;
  const alt_32 angle_first = 0;

  alt_32 angle_cordic = angle_start;
  alt_32 sincos, sin, cos;

  while(1) {
    // Get elipse parameters.
    elipse_a = IORD_32DIRECT(ELIPSE_A_IN_BASE, 0);
    elipse_b = IORD_32DIRECT(ELIPSE_B_IN_BASE, 0);

    if (angle_cordic > angle_last) {
      angle_cordic = angle_first;
    }

    IOWR(CORDIC_PIPELINE_AVALON_INTERFACE_0_BASE, 0, (angle_cordic)); // Write the angle to cordic processor.

    sincos = IORD_32DIRECT(CORDIC_PIPELINE_AVALON_INTERFACE_0_BASE, 0);
    sin = sincos         & 0xfff; // bits 0-11
    cos = (sincos >> 16) & 0xfff; // bits 16-27

    coord_x = elipse_a * cos;
    coord_y = elipse_b * sin;

    IOWR(ELIPSE_X_OUT_BASE, 0, (coord_x)); // Export x coordinate.
    IOWR(ELIPSE_Y_OUT_BASE, 0, (coord_y)); // Export y coordinate.

    angle_cordic += 64;
  }
}


//   file copy -force /media/piko/SeagateBackupPlusDrive/intelFPGA_lite/19.1/cordic_lab/software/Application_Cordic/mem_init/nios_cordic_system_RAM.hex ./