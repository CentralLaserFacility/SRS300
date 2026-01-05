# Stanford Research Systems HVPSU 300-series Controller
SRS300 Series Controller &amp; GUI.

EPICS IOC and GUI to control SRS 300-series High voltage power supplies.

The controller displays device information such as present voltage and current, presence of any trips or errors, and device limits/settings.
The controller allows users to ramp up the voltage to a target over a user-specified amount of time.
Using automatic mode, the controller allows the user to input a target voltage and ramp time then will calculate the step size and interval between steps. A manual mode for user-set step size and interval is also available.
After a new voltage is set (including each increment of the ramp) the device requires around 1.3-1.4 seconds to stabilize before it can be accurately read so there is a minimum interval of 1.5 seconds to allow for this.
The controller uses configMenu to allow users to save ramp settings which can then be loaded in later.
To allow for substitutions to change dynamically, sequence records are used to set limits on start and may be used to set new limits during run time if polarity is switched.

Written and tested using EPICS base R7.0.8.1.
