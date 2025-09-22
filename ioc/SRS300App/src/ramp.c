#include <stdio.h>
#include <aSubRecord.h>
#include <epicsExport.h>
#include <registryFunction.h>

//output a: current voltage
//output b: event, whether to reprocess record



static long rampcalc(aSubRecord *precord){
    double startVoltage, targetVoltage, rampTime, voltageDiff, interval, minStepSize, stepSize, 
    minInterval, readDelay, checkFactor;
    short mode; 

    startVoltage = *(double*)precord->a;
    targetVoltage = *(double*)precord->b;
    rampTime = *(double*)precord->c;
    stepSize = *(double*)precord->d;
    mode = *(short*)precord->e; //0 = auto, 1 = manual
    interval = *(double*)precord->f;
    minStepSize = *(double*)precord->g;
    minInterval = *(double*)precord->h;
    readDelay = *(double*)precord->i; //time to wait after setting voltage

    if (mode == 0) {
        //this just makes voltage difference positive for calculation
        //could use abs() but don't want to add another library for just this
        if(targetVoltage> startVoltage){
            voltageDiff = targetVoltage - startVoltage;
        }
        else{
            voltageDiff = startVoltage - targetVoltage;
        }

        stepSize = minStepSize;
            //calc interval using 2xminimum as a min step size to avoid too fast ramping
        interval = rampTime/(voltageDiff / stepSize);

        if (interval < minInterval){
            //calculation to find new interval based on minimum interval
            //this works by checking if the minimum interval is a factor of the ramp time
            //if not, it rounds down to the nearest whole number factor and divides ramp time by that
            //this finds the lowest number it can use that is above the minimum interval
            interval = minInterval;
            checkFactor = rampTime/interval; //is interval a factor of ramp time?
            if ((short)checkFactor < checkFactor){//if not a whole number
                checkFactor = (short)checkFactor; //round DOWN to nearest whole number
                interval = rampTime/checkFactor; //recalc interval to be a factor of ramp time
            }
            //recalc step size with new interval
            stepSize = voltageDiff/( rampTime/ interval);
                if ( ((short)stepSize) < stepSize) { //is step size decimal?
                    stepSize = (short)stepSize + 1;//round up to nearest whole number
                    interval = rampTime/(voltageDiff / stepSize);//recalc interval with new step size
                }

            }
        }
    else{
        if (interval < minInterval){
            readDelay = minInterval-0.1; 
            //if interval is manually set below minimum, read voltage as late as possible after being set
            //the delay is to account for stabilizing before being read so we want as close to 1.4 seconds as possible
            //without going over the interval where the next one will be set
            //(there will be GUI warning for this)

        }
    }
    


   *(double*)precord->vala = stepSize;
   *(double*)precord->valb = interval;
   *(double*)precord->valc = readDelay;
   *(short*)precord->vald = 1; //event to process ramp

    return 0;
}

epicsRegisterFunction(rampcalc);
