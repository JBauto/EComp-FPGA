#include "xparameters.h"
#include "xgpio.h"

//This is a macro that gets my GPIO ID from the parameters file xparameters.h
#define MY_GPIO_ID XPAR_LEDS_OUTPUT_GPIO_DEVICE_ID

//This is a delay between updates in the leds, or we will not be able to visualize it
#define LED_DELAY     1000000

//following constant is used to determine which channel of the GPIO is
//used if there are 2 channels supported in the GPIO.
#define LED_CHANNEL 1

//This is the width we set for the GPIO */
#define GPIO_BITWIDTH   8

//FSL related macros
#ifdef XPAR_FSL_FSL_EXAMPLE_0_INPUT_SLOT_ID
	#define input_slot_id   XPAR_FSL_FSL_EXAMPLE_0_INPUT_SLOT_ID
	#define output_slot_id  XPAR_FSL_FSL_EXAMPLE_0_OUTPUT_SLOT_ID
	#include "fsl.h" 
	#define write_into_fsl(val, id)  putfsl(val, id)
	#define read_from_fsl(val, id)  getfsl(val, id)
#endif


int main(void)
{
	//this variable will contain the value presented in the leds
	unsigned int OutData;
	//this is the driver for our GPIO
	XGpio GpioDrv;
	//delay control variable
	int DelayCtl;
	 
	 
	 //Initialize the GPIO driver so that it's ready to use,
	 //specify the device ID that is generated in xparameters.h
	 XGpio_Initialize(&GpioDrv, MY_GPIO_ID);


    //Set the direction for all signals to be outputs
    XGpio_SetDataDirection(&GpioDrv, LED_CHANNEL, 0x0);

	//we will perform a rotacional shift of the light in the leds
	OutData = 0x01;
	while(1)
	{
		#ifndef XPAR_FSL_FSL_EXAMPLE_0_INPUT_SLOT_ID
		if(OutData & 0x80)
			OutData = 0x01;
		else
			OutData <<= 1;
		#else
		write_into_fsl(OutData, input_slot_id);
		read_from_fsl(OutData, output_slot_id);
		#endif
		
		//write to the correct channel of the GPIO
		XGpio_DiscreteWrite(&GpioDrv, LED_CHANNEL, OutData);
	
		//apply the delay before next update
		for(DelayCtl = 0; DelayCtl < LED_DELAY; DelayCtl++);
		
	}

    return 0;
}
