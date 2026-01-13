program rampLogic
%%#define RAMPING 1
%%#define IDLE 0
%%#define REGULAR_SCAN 6 //regular scan = 1 second
//to change default scan see scan menu and change 6 accordingly
%%#define PASSIVE 0 // 0 = passive scanning
%%#define END 1 // 1 = ramp ended
%%#define SCAN_DELAY 1.45 //delay time for voltage to stabilize after setting new voltage
%%#define RAMP_UP 1
%%#define RAMP_DOWN 0
%%#define DISABLED 0
%%#define ENABLED 1

double presentVoltage;
double targetVoltage;
double stepSize;
double interval;
short startCharge;// 1 = ramping, 0 = Idle
double HVset;
short voltageMonitorScan; 
double minStepSize;
short Tolerance; //Tolerance for stopping ramping
double newVoltage;
short endCharge; // 1 = ramp ended, 0 = not ended
short rampDirection; // 1 = ramp up, 0 = ramp down
short monitorPROC;
short HVonStatus; // 1 = HV on, 0 = HV off


assign presentVoltage to "{DEVICE}:OutputVget";
assign targetVoltage to "{DEVICE}:desiredHV";
assign stepSize to "{DEVICE}:VRAMPstepSize";
assign interval to "{DEVICE}:VRAMPinterval";
assign startCharge to "{DEVICE}:VRAMPactive";
assign HVset to "{DEVICE}:HVset";
assign voltageMonitorScan to "{DEVICE}:voltageMonitor.SCAN";
assign monitorPROC to "{DEVICE}:voltageMonitor.PROC";
assign minStepSize to "{DEVICE}:C_minStepSize"; 
assign Tolerance to "{DEVICE}:C_Tolerance";
assign endCharge to "{DEVICE}:endCharge";
assign HVonStatus to "{DEVICE}:HVONstatus";

monitor presentVoltage;
monitor targetVoltage;
monitor stepSize;
monitor interval;
monitor startCharge;
monitor minStepSize;
monitor Tolerance;
monitor HVonStatus;

ss RampState{

    state initial{//stays idle then decides rampup or rampdown once started
        when (startCharge == IDLE || presentVoltage==targetVoltage){
            //do nothing, stay idle
        } state initial
        when (startCharge == RAMPING && HVonStatus == DISABLED){
            //if HV is off, do not ramp
            startCharge = IDLE;
            endCharge = END;
            voltageMonitorScan = REGULAR_SCAN;
            pvPut(startCharge);
            pvPut(endCharge);
            pvPut(voltageMonitorScan);
        } state initial
        when (startCharge == RAMPING && presentVoltage<targetVoltage && HVonStatus == ENABLED){
            //status scanning must be paused while voltage is being set
            rampDirection = RAMP_UP;
            voltageMonitorScan = PASSIVE;//set to passive scanning before ramping
            pvPut(voltageMonitorScan); 
        } state RampUp
        when (startCharge == RAMPING && presentVoltage>targetVoltage && HVonStatus == ENABLED){
            rampDirection = RAMP_DOWN;
            voltageMonitorScan = PASSIVE;
            pvPut(voltageMonitorScan); 
        } state RampDown
    }

    state RampUp{
        when (presentVoltage < targetVoltage-Tolerance && startCharge == RAMPING && HVonStatus == ENABLED){
            newVoltage = presentVoltage + stepSize;
            if (newVoltage > targetVoltage-minStepSize){ //safety check
                //if the next step is smaller than minStepSize, set straight to target instead
                newVoltage = targetVoltage;
            }
            HVset = newVoltage;
            pvPut(HVset);
        } state StableDelay 

        when (presentVoltage >= (targetVoltage-Tolerance) || startCharge == IDLE || HVonStatus == DISABLED){ //stops ramping and returns to initial
            startCharge = IDLE;
            endCharge = END;
            voltageMonitorScan = REGULAR_SCAN;
            pvPut(startCharge);
            pvPut(endCharge);
            pvPut(voltageMonitorScan);
        } state initial
    }

    state RampDown{ 
        when (presentVoltage > targetVoltage+Tolerance && startCharge == RAMPING && HVonStatus == ENABLED){
            newVoltage = presentVoltage - stepSize;
            if (newVoltage < targetVoltage+minStepSize){ //safety check
                //if the next step is smaller than minStepSize, set straight to target instead
                newVoltage = targetVoltage;
            }
            HVset = newVoltage;
            pvPut(HVset);
            
        } state StableDelay 

        when (presentVoltage<=(targetVoltage+Tolerance) || startCharge == IDLE || HVonStatus == DISABLED){ //stops ramping and returns to initial
            startCharge = IDLE;
            endCharge = END;
            voltageMonitorScan = REGULAR_SCAN;
            pvPut(startCharge);
            pvPut(endCharge);
            pvPut(voltageMonitorScan);
        } state initial
    }

//_____states for delays_______
//_____________________________

    state StableDelay{ 
        when (delay(SCAN_DELAY)){// delays by 1.45 seconds to allow voltage to stabilize
            //set back to regular scanning while safe
            voltageMonitorScan = REGULAR_SCAN;
            pvPut(voltageMonitorScan);
            monitorPROC = 1; //force to update immediately after delay
            pvPut(monitorPROC);
        } state IntervalDelay
    }

    state IntervalDelay{ 
        when ((delay(interval-SCAN_DELAY)) && (rampDirection == RAMP_UP)){// delays by rest of interval time
            monitorPROC = 1; //force to update immediately before next ramp step
            pvPut(monitorPROC);
            voltageMonitorScan = PASSIVE;//set back to passive scanning before ramping
            pvPut(voltageMonitorScan);          
        } state RampUp

        when ((delay(interval-SCAN_DELAY)) && (rampDirection == RAMP_DOWN)){// delays by rest of interval time
            voltageMonitorScan = PASSIVE;//set back to passive scanning before ramping
            pvPut(voltageMonitorScan);            
        } state RampDown
    }
}