//main.c
#include "io.h"  // required for IOWR
#include "alt_types.h" // required for alt_u32
#include "system.h"  // contains address of CORDIC_PIPELINE_AVALON_INTERFACE_0_BASE

#define angle_in (volatile char *) ANGLE_IN_BASE
#define cordic_av_interface (char *) CORDIC_PIPELINE_AVALON_INTERFACE_0_BASE

int main(){
    alt_u32 angle_in_value = 0x0001; // 0x0283;

    printf("HELLO FROM CORDIC PROCESSOR\n");
    while(1){


      // *angle_in = *cordic_av_interface;

      // IORD(ANGLE_IN_BASE, angle_in_value);
      for (angle_in_value = 0x0001; angle_in_value < 0x0c8d; angle_in_value++) {
        IOWR(CORDIC_PIPELINE_AVALON_INTERFACE_0_BASE, 0, (angle_in_value)); // write the angle_in

      // printf("IOWR angle: angle_in = %f\n", angle_in);
      }
  }
}


//   file copy -force /media/piko/SeagateBackupPlusDrive/intelFPGA_lite/19.1/cordic_lab/software/Application_Cordic/mem_init/nios_cordic_system_RAM.hex ./