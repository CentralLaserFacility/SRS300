#include <stdio.h>
#include <aSubRecord.h>
#include <epicsExport.h>
#include <registryFunction.h>

//output a: current voltage
//output b: event, whether to reprocess record



static long rampcalc(aSubRecord *precord){
    double startVoltage, targetVoltage, rampTime;
    short stepSize; 
    float tempStepSize, tempInterval, interval;

    startVoltage = *(double*)precord->a;
    targetVoltage = *(double*)precord->b;
    rampTime = *(double*)precord->c;
    stepSize = *(double*)precord->d;
    mode = *(short*)precord->e; //1 = auto, 0 = manual

   if(mode==1){ //***
        tempStepSize = 200;
        //calc interval using 200 as a min step size to avoid too fast ramping
        tempInterval = rampTime/((targetVoltage - startVoltage) / stepSize);
        if (tempInterval < 1){
            tempInterval = 1;
            tempStepSize = rampTime/((targetVoltage - startVoltage) / tempInterval);
            if (tempStepSize % 1 != 0){
                tempStepSize = (short)tempStepSize + 1;
                tempInterval = rampTime/((targetVoltage - startVoltage) / stepSize);
            }
        }
        stepSize = (short)tempStepSize;
        interval = tempInterval;
   }

    
   *(short*)precord->vala = interval;
   *(short*)precord->valb = stepSize;
    return 0;
}

epicsRegisterFunction(rampcalc);
