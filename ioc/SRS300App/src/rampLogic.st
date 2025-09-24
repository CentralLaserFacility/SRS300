program rampLogic

double presentVoltage;
double targetVoltage;
double stepSize;
float interval;
enum startCharge;
double HVset;
enum voltageMonitorScan;
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
        when (startCharge == "Ramping" && presentVoltage<targetVoltage){
        } state RampUp
        when (startCharge == "Ramping" && presentVoltage>targetVoltage){
        } state RampDown
        when (startCharge == "Idle" || presentVoltage==targetVoltage){
        } state initial
    }

    state RampUp{
        when (presentVoltage < targetVoltage-Tolerance && startCharge == "Ramping"){
            printf("Ramping Up\n");
            newVoltage = presentVoltage + stepSize;
            if (newVoltage > targetVoltage-minStepSize){ //safety check
                //if the next step is smaller than minStepSize, set straight to target instead
                newVoltage = targetVoltage;
                printf("final\n");
            }
            HVset = newVoltage;
            pvPut(HVset);

        } state RampupDelay 

        when (presentVoltage >= (targetVoltage-Tolerance) || startCharge == "Idle"){ //stops ramping and returns to initial
            startCharge = "Idle";
            printf("Ramping Complete\n");
            voltageMonitorScan = "1 second";
            voltageMonitorDelay = "0";
            pvPut(voltageMonitorScan);
            pvPut(voltageMonitorDelay);
            pvPut(startCharge);
        } state initial
    }

    state RampupDelay{ // delays by interval time
        when (delay(interval)){
            printf("Delay over\n");
        } state RampUp
    }

    state RampDown{ 
        when (presentVoltage > targetVoltage+Tolerance && startCharge == "Ramping"){
            newVoltage = presentVoltage - stepSize;
            if (newVoltage < targetVoltage+minStepSize){ //safety check
                //if the next step is smaller than minStepSize, set straight to target instead
                newVoltage = targetVoltage;
            }
            HVset = newVoltage;
            pvPut(HVset);

        } state RampDownDelay 


        when (presentVoltage<=(targetVoltage+Tolerance) || startCharge == "Idle"){ //stops ramping and returns to initial
            startCharge = "Idle";
            voltageMonitorScan = "1 second";
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

