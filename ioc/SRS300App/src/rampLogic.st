program rampLogic
%%#define RAMPING 1
%%#define IDLE 0
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
short StartCharge;// 1 = ramping, 0 = Idle
double HVset;
short VoltageMonitorScan; 
short RegularScan; 
double MinStepSize;
short Tolerance; //Tolerance for stopping ramping
double newVoltage;
short EndCharge; // 1 = ramp ended, 0 = not ended
short rampDirection; // 1 = ramp up, 0 = ramp down
short monitorPROC;
short HVonStatus; // 1 = HV on, 0 = HV off


assign presentVoltage to "{DEVICE}:OutputVget";
assign targetVoltage to "{DEVICE}:TargetHV";
assign stepSize to "{DEVICE}:RampStepSize";
assign interval to "{DEVICE}:RampInterval";
assign StartCharge to "{DEVICE}:RampActive";
assign HVset to "{DEVICE}:HVset";
assign VoltageMonitorScan to "{DEVICE}:VoltageMonitor.SCAN";
assign RegularScan to "{DEVICE}:ReadbackPoll.SCAN";
assign monitorPROC to "{DEVICE}:VoltageMonitor.PROC";
assign MinStepSize to "{DEVICE}:MinStepSize"; 
assign Tolerance to "{DEVICE}:Tolerance";
assign EndCharge to "{DEVICE}:EndCharge";
assign HVonStatus to "{DEVICE}:HVONstatus";

monitor presentVoltage;
monitor targetVoltage;
monitor stepSize;
monitor interval;
monitor StartCharge;
monitor MinStepSize;
monitor Tolerance;
monitor HVonStatus;
monitor RegularScan;

ss RampState{

    state initial{//stays idle then decides rampup or rampdown once started
        when (StartCharge == IDLE || presentVoltage==targetVoltage){
            //do nothing, stay idle
        } state initial
        when (StartCharge == RAMPING && HVonStatus == DISABLED){
            //if HV is off, do not ramp
            StartCharge = IDLE;
            EndCharge = END;
            VoltageMonitorScan = RegularScan;
            pvPut(StartCharge);
            pvPut(EndCharge);
            pvPut(VoltageMonitorScan);
        } state initial
        when (StartCharge == RAMPING && presentVoltage<targetVoltage && HVonStatus == ENABLED){
            //status scanning must be paused while voltage is being set
            rampDirection = RAMP_UP;
            VoltageMonitorScan = PASSIVE;//set to passive scanning before ramping
            pvPut(VoltageMonitorScan); 
        } state RampUp
        when (StartCharge == RAMPING && presentVoltage>targetVoltage && HVonStatus == ENABLED){
            rampDirection = RAMP_DOWN;
            VoltageMonitorScan = PASSIVE;
            pvPut(VoltageMonitorScan); 
        } state RampDown
    }

    state RampUp{
        when (presentVoltage < targetVoltage-Tolerance && StartCharge == RAMPING && HVonStatus == ENABLED){
            newVoltage = presentVoltage + stepSize;
            if (newVoltage > targetVoltage-MinStepSize){ //safety check
                //if the next step is smaller than MinStepSize, set straight to target instead
                newVoltage = targetVoltage;
            }
            HVset = newVoltage;
            pvPut(HVset);
        } state StableDelay 

        when (presentVoltage >= (targetVoltage-Tolerance) || StartCharge == IDLE || HVonStatus == DISABLED){ //stops ramping and returns to initial
            StartCharge = IDLE;
            EndCharge = END;
            VoltageMonitorScan = RegularScan;
            pvPut(StartCharge);
            pvPut(EndCharge);
            pvPut(VoltageMonitorScan);
        } state initial
    }

    state RampDown{ 
        when (presentVoltage > targetVoltage+Tolerance && StartCharge == RAMPING && HVonStatus == ENABLED){
            newVoltage = presentVoltage - stepSize;
            if (newVoltage < targetVoltage+MinStepSize){ //safety check
                //if the next step is smaller than MinStepSize, set straight to target instead
                newVoltage = targetVoltage;
            }
            HVset = newVoltage;
            pvPut(HVset);
            
        } state StableDelay 

        when (presentVoltage<=(targetVoltage+Tolerance) || StartCharge == IDLE || HVonStatus == DISABLED){ //stops ramping and returns to initial
            StartCharge = IDLE;
            EndCharge = END;
            VoltageMonitorScan = RegularScan;
            pvPut(StartCharge);
            pvPut(EndCharge);
            pvPut(VoltageMonitorScan);
        } state initial
    }

//_____states for delays_______
//_____________________________

    state StableDelay{ 
        when (delay(SCAN_DELAY)){// delays by 1.45 seconds to allow voltage to stabilize
            //set back to regular scanning while safe
            VoltageMonitorScan = RegularScan;
            pvPut(VoltageMonitorScan);
            monitorPROC = 1; //force to update immediately after delay
            pvPut(monitorPROC);
        } state IntervalDelay
    }

    state IntervalDelay{ 
        when ((delay(interval-SCAN_DELAY)) && (rampDirection == RAMP_UP)){// delays by rest of interval time
            monitorPROC = 1; //force to update immediately before next ramp step
            pvPut(monitorPROC);
            VoltageMonitorScan = PASSIVE;//set back to passive scanning before ramping
            pvPut(VoltageMonitorScan);          
        } state RampUp

        when ((delay(interval-SCAN_DELAY)) && (rampDirection == RAMP_DOWN)){// delays by rest of interval time
            VoltageMonitorScan = PASSIVE;//set back to passive scanning before ramping
            pvPut(VoltageMonitorScan);            
        } state RampDown
    }
}