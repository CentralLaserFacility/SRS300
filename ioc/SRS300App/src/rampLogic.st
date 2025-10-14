program rampLogic
%%#define RAMPING 1
%%#define IDLE 0
%%#define REGULAR_SCAN 6 //regular scan = 1 second
//to change default scan see scan menu and change 6 accordingly
%%#define PASSIVE 0 // 0 = passive scanning
%%#define END 1 // 1 = ramp ended

double presentVoltage;
double targetVoltage;
double stepSize;
double interval;
short startCharge;// 1 = ramping, 0 = Idle
double HVset;
short voltageMonitorScan; 
double voltageMonitorDelay;
double minStepSize;
short Tolerance; //Tolerance for stopping ramping
double newVoltage;
double readbackPollScan;
short endCharge; // 1 = ramp ended, 0 = not ended

assign presentVoltage to "{P}{R}OutputVget"; //change $(P)$(R) syntax
assign targetVoltage to "{P}{R}desiredHV";
assign stepSize to "{P}{R}VRAMPstepSize";
assign interval to "{P}{R}VRAMPinterval";
assign startCharge to "{P}{R}VRAMPactive";
assign HVset to "{P}{R}HVset";
assign voltageMonitorScan to "{P}{R}voltageMonitor.SCAN";
assign voltageMonitorDelay to "{P}{R}voltageMonitor.DLY1";
assign minStepSize to "{P}{R}C_minStepSize"; 
assign Tolerance to "{P}{R}C_Tolerance";
assign readbackPollScan to "{P}{R}ReadbackPoll_.SCAN";
assign endCharge to "{P}{R}endCharge";

monitor presentVoltage;
monitor targetVoltage;
monitor stepSize;
monitor interval;
monitor startCharge;
monitor minStepSize;
monitor Tolerance;

ss RampState{

    state initial{//stays idle then decides rampup or rampdown once started
        when (startCharge == RAMPING && presentVoltage<targetVoltage){
            readbackPollScan = PASSIVE;//status scanning must be paused while voltage is being set
            pvPut(readbackPollScan);
        } state RampUp
        when (startCharge == RAMPING && presentVoltage>targetVoltage){
            readbackPollScan = PASSIVE;
            pvPut(readbackPollScan);
        } state RampDown
        when (startCharge == IDLE || presentVoltage==targetVoltage){
        } state initial
    }

    state RampUp{
        when (presentVoltage < targetVoltage-Tolerance && startCharge == RAMPING){
            newVoltage = presentVoltage + stepSize;
            if (newVoltage > targetVoltage-minStepSize){ //safety check
                //if the next step is smaller than minStepSize, set straight to target instead
                newVoltage = targetVoltage;
            }
            HVset = newVoltage;
            pvPut(HVset);
            readbackPollScan = REGULAR_SCAN;//set back to regular scanning while safe
            pvPut(readbackPollScan);
        } state RampupDelay 

        when (presentVoltage >= (targetVoltage-Tolerance) || startCharge == IDLE){ //stops ramping and returns to initial
            startCharge = IDLE;
            endCharge = END;
            pvPut(startCharge);
            pvPut(endCharge);
        } state initial
    }

    state RampupDelay{ // delays by interval time
        when (delay(interval)){
            readbackPollScan = PASSIVE;
            pvPut(readbackPollScan);
        } state RampUp
    }

    state RampDown{ 
        when (presentVoltage > targetVoltage+Tolerance && startCharge == RAMPING){
            newVoltage = presentVoltage - stepSize;
            if (newVoltage < targetVoltage+minStepSize){ //safety check
                //if the next step is smaller than minStepSize, set straight to target instead
                newVoltage = targetVoltage;
            }
            HVset = newVoltage;
            pvPut(HVset);
            readbackPollScan = REGULAR_SCAN;//set back to regular scanning while safe
            pvPut(readbackPollScan);
            
        } state RampDownDelay 


        when (presentVoltage<=(targetVoltage+Tolerance) || startCharge == IDLE){ //stops ramping and returns to initial
            startCharge = IDLE;
            endCharge = END;
            pvPut(startCharge);
            pvPut(endCharge);
        } state initial
    }   
    state RampDownDelay{ // delays by interval time
        when (delay(interval)){
            readbackPollScan = PASSIVE;
            pvPut(readbackPollScan);
        } state RampDown
    }
}

