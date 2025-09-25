program rampLogic

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

monitor presentVoltage;
monitor targetVoltage;
monitor stepSize;
monitor interval;
monitor startCharge;
monitor minStepSize;
monitor Tolerance;

ss RampState{

    state initial{//stays idle then decides rampup or rampdown once started
        when (startCharge == 1 && presentVoltage<targetVoltage){
        } state RampUp
        when (startCharge == 1 && presentVoltage>targetVoltage){
        } state RampDown
        when (startCharge == 0 || presentVoltage==targetVoltage){
        } state initial
    }

    state RampUp{
        when (presentVoltage < targetVoltage-Tolerance && startCharge == 1){
            newVoltage = presentVoltage + stepSize;
            if (newVoltage > targetVoltage-minStepSize){ //safety check
                //if the next step is smaller than minStepSize, set straight to target instead
                newVoltage = targetVoltage;
            }
            HVset = newVoltage;
            pvPut(HVset);

        } state RampupDelay 

        when (presentVoltage >= (targetVoltage-Tolerance) || startCharge == 0){ //stops ramping and returns to initial
            startCharge = 0;
            // refer to scan menu, 6 refers to "1 second"
            // so setting scan to 6 scans every 1 second
            voltageMonitorScan = 6; 
            voltageMonitorDelay = 0;
            pvPut(voltageMonitorScan);
            pvPut(voltageMonitorDelay);
            pvPut(startCharge);
        } state initial
    }

    state RampupDelay{ // delays by interval time
        when (delay(interval)){
        } state RampUp
    }

    state RampDown{ 
        when (presentVoltage > targetVoltage+Tolerance && startCharge == 1){
            newVoltage = presentVoltage - stepSize;
            if (newVoltage < targetVoltage+minStepSize){ //safety check
                //if the next step is smaller than minStepSize, set straight to target instead
                newVoltage = targetVoltage;
            }
            HVset = newVoltage;
            pvPut(HVset);

        } state RampDownDelay 


        when (presentVoltage<=(targetVoltage+Tolerance) || startCharge == 0){ //stops ramping and returns to initial
            startCharge = 0;
            // refer to scan menu, 6 refers to "1 second"
            // so setting scan to 6 scans every 1 second
            voltageMonitorScan = 6; 
            voltageMonitorDelay = 0;
            pvPut(voltageMonitorScan);
            pvPut(voltageMonitorDelay);
            pvPut(startCharge);
        } state initial
    }   
    state RampDownDelay{ // delays by interval time
        when (delay(interval)){
        } state RampDown
    }
}

