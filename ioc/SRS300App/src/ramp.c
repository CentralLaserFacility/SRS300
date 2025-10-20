#include <stdio.h>
#include <aSubRecord.h>
#include <epicsExport.h>
#include <registryFunction.h>
#include <string.h>

//calculates step size and interval based on user input of target voltage and ramp time
//time interval between steps is calculated based on step size being equal to minimum
//if calculated interval is below minimum interval, interval is set to a factor of the total time that is above the minimum
//step size is recalculated based on the new interval

static long rampcalc(aSubRecord *precord){
    double startVoltage, targetVoltage, rampTime, voltageDiff, interval, minStepSize, stepSize, 
    minInterval, checkFactor;
    char *mode;
    short miniHop, active;

    startVoltage = *(double*)precord->a;
    targetVoltage = *(double*)precord->b;
    rampTime = *(double*)precord->c;
    stepSize = *(double*)precord->d;
    mode = (char*)precord->e;
    interval = *(double*)precord->f;
    minStepSize = *(double*)precord->g;
    minInterval = *(double*)precord->h;
    
    //if voltage already reached do not continue
    if(startVoltage == targetVoltage){
        return 1;
    }

    //this just makes voltage difference positive for calculation
    //could use abs() but don't want to add another library for just this
    if(targetVoltage> startVoltage){
        voltageDiff = targetVoltage - startVoltage;
    }
    else{
        voltageDiff = startVoltage - targetVoltage;
    }
    if(voltageDiff == 0){
        return 1; //if present voltage is the same as target send error and do not output
    }


    miniHop = 0; //*** Magic numbers
    active = 1;
    //if target voltage requires step below minimum step size, output error message
    if(voltageDiff<minStepSize){
        active = 0;
        miniHop = 1;
    }

    if (strcmp(mode, "Automatic") == 0) {//if mode = automatic
        //check for possible divide by 0 errors
        if (minStepSize == 0){
            minStepSize = 1; //ensure step size cannot be 0
        }

        stepSize = minStepSize;
        //calc interval using 2xminimum as a min step size to avoid too fast ramping
        interval = rampTime/(short)(voltageDiff / stepSize);

        if (interval < minInterval){
            //calculation to find new interval based on minimum interval
            //this works by checking if the minimum interval is a factor of the ramp time
            //if not, it rounds down to the nearest whole number factor and divides ramp time by that
            //this finds the lowest number it can use that is above the minimum interval
            interval = minInterval;
            checkFactor = rampTime/interval; //is interval a factor of ramp time?
            if ((short)checkFactor < checkFactor){//if not a whole number
                if ((short)(rampTime/2) < rampTime/2){//if ramp time is not even
                    checkFactor = (short)checkFactor; //round DOWN to nearest whole number
                    interval = rampTime/checkFactor; //recalc interval to be a factor of ramp time
                }
                else{
                    interval = 2;//if ramp time is even set interval to 2 seconds
                }
            }
            //recalc step size with new interval
            stepSize = voltageDiff/( rampTime/ interval);
                if ( ((short)stepSize) < stepSize) { //is step size decimal?
                    stepSize = (short)stepSize + 1;//round up to nearest whole number
                }
            }
        }
    else{
        //shows how long ramping will take based on user's manual input
        rampTime = (interval*(short)(voltageDiff/stepSize));
        if(rampTime<interval){
            rampTime=interval;
        }
    }
   *(double*)precord->vala = stepSize;
   *(double*)precord->valb = interval;
   *(short*)precord->valc = active; //event to process ramp
   *(short*)precord->vald = miniHop;//is the increase too small?
   *(double*)precord->vale = rampTime;
    return 0;
}

epicsRegisterFunction(rampcalc);
