program rampLogic

double presentVoltage;
double targetVoltage;
double stepSize;
float interval;
double startCharge;
double HVset;
double voltageMonitorScan;
double voltageMonitorDelay;
double minStepSize;
short Prec; //precision for stopping ramping
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
assign Prec to "{P}{R}C_Precision";

monitor presentVoltage;
monitor targetVoltage;
monitor stepSize;
monitor interval;
monitor startCharge;// 1=Ramping, 0=Idle
monitor minStepSize;
monitor Prec;

ss RampState{

    state initial{/*stays idle then decides rampup or rampdown once started*/
        when (startCharge == 1 && presentVoltage<targetVoltage){
        } state RampUp
        when (startCharge == 1 && presentVoltage>targetVoltage){
        } state RampDown
        when (startCharge == 0 || presentVoltage==targetVoltage){
        } state initial
    }

    state RampUp{
        when (presentVoltage < targetVoltage-Prec && startCharge == 1){
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

        when (presentVoltage >= (targetVoltage-Prec) || startCharge == 0){ //stops ramping and returns to initial
            startCharge = 0;
            printf("Ramping Complete\n");
            //"scan" menu represents 1 second as "6" so this sets to scan normally again (1 second)
            voltageMonitorScan = 6;
            voltageMonitorDelay = 0;
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
        when (presentVoltage > targetVoltage+Prec && startCharge == 1){
            newVoltage = presentVoltage - stepSize;
            if (newVoltage < targetVoltage+minStepSize){ //safety check
                //if the next step is smaller than minStepSize, set straight to target instead
                newVoltage = targetVoltage;
            }
            HVset = newVoltage;
            pvPut(HVset);

        } state RampDownDelay 


        when (presentVoltage<=(targetVoltage+Prec) || startCharge == 0){ //stops ramping and returns to initial
            startCharge = 0;
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

