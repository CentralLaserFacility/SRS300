#include <stdio.h>
#include <aSubRecord.h>
#include <epicsExport.h>
#include <registryFunction.h>

//output a: current voltage
//output b: event, whether to reprocess record



static long rampcalc(aSubRecord *precord){
    double startVoltage, targetVoltage, rampTime, voltageDiff;
    short stepSize; 
    float tempStepSize, tempInterval, interval;

    startVoltage = *(double*)precord->a;
    targetVoltage = *(double*)precord->b;
    rampTime = *(double*)precord->c;
    stepSize = *(double*)precord->d;
    //mode = *(short*)precord->e; //1 = auto, 0 = manual
    if(targetVoltage> startVoltage){
        voltageDiff = targetVoltage - startVoltage;
    }
    else{
        voltageDiff = startVoltage - targetVoltage;
    }

    tempStepSize = 100;
        //calc interval using 200 as a min step size to avoid too fast ramping
    tempInterval = rampTime/(voltageDiff / stepSize);
    if (tempInterval < 2){
        tempInterval = 2;
        tempStepSize = voltageDiff/( rampTime/ tempInterval);
            if ( ((short)tempStepSize) < tempStepSize) { //if not integer round up
                tempStepSize = (short)tempStepSize + 1;
                tempInterval = rampTime/(voltageDiff / stepSize);
            }

        }
        stepSize = (short)tempStepSize;
        interval = tempInterval;

    
   *(double*)precord->vala = stepSize;
   *(double*)precord->valb = interval;
   *(short*)precord->valc = 1; //event to process ramp
    return 0;
}

epicsRegisterFunction(rampcalc);
