#include <stdio.h>
#include <aSubRecord.h>
#include <epicsExport.h>
#include <registryFunction.h>

//output a: current voltage
//output b: event, whether to reprocess record


static long rampup(aSubRecord *precord)
{
    double currentVoltage; // Current voltage
    double targetVoltage; // Target voltage 
    double stepSize;     // Step size
    short interval; // Time interval in seconds

    currentVoltage = *(double*)precord->a;
    targetVoltage = *(double*)precord->b;
    stepSize = *(double*)precord->c;
    interval = *(short*)precord->d;

    if (currentVoltage == targetVoltage){
        return 1;
    }
    //if current voltage is within a step of target voltage
    else if(currentVoltage + stepSize > targetvoltage-100){
        *(double *)precord->vala = targetVoltage;
        *(double *)precord->valb = 0;
    }

    else {
        *(double *)precord->vala = currentVoltage + stepSize;
        *(double *)precord->valb = 1;
    }
    //sleep(interval);
    return 0;
}

static long rampcalc(aSubRecord *precord){
    double startVoltage, targetVoltage, rampTime;
    short mode, stepSize, interval;

    startVoltage = *(double*)precord->a;
    targetVoltage = *(double*)precord->b;
    rampTime = *(double*)precord->c;
    stepSize = *(double*)precord->d;
    //mode = *(short*)precord->d;

   // Calculate the required interval (fixed step size)
    interval = rampTime/((targetVoltage - startVoltage) / stepSize);

   *(short*)precord->vala = interval;
    return 0;
}