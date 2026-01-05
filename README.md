# Stanford Research Systems HVPSU 300-series Controller
EPICS IOC and GUI to control SRS 300-series High voltage power supplies.

## Overview
The controller allows users to ramp the device's voltage up to a target over a user-specified period of time

The controller also displays device information such as present voltage and current, presence of any trips or errors, and device limits/settings.

## Voltage ramping
Using automatic mode, the controller allows the user to input a target voltage and ramp time then will calculate the step size and interval between steps. A manual mode for user-set step size and interval is also available.

After a new voltage is set (including each increment of the ramp) the device requires around 1.3-1.4 seconds to stabilize before it can be accurately read so there is a delay of 1.45 seconds after each increment. There is aminimum interval of 1.5 seconds to allow for this.
By default the step size is the device's minimum voltage.

For safe ramping:

- If the HVPSU is connected to a device, the ramp time should not be too fast and should be at minimum 15 seconds from 100V to 20kV to prevent a trip (exact values vary between devices and is at user's discretion).
- If a user is unsure as to appropriate values for ramping of a device, configMenu is used so that users can save and load in settings other users have used with titles and descriptions.

## Substitutions, limits and inputs
To allow for substitutions to change dynamically, sequence records are used to set limits on start and may be used to set new limits during run time if polarity is switched.

If the device's polarity is negative, inputs regarding voltage must include the negative sign. Occasionally on startup the input boxes on the GUI don't respond well to this, if an issue ocurs there is a refresh button on the top left corner of the screen which fixes it.

There are two 'popup' menus in the GUI, one for ramp configurations and the other for device limits (voltage maximum, current maximum and current trip limit) both can be accessed via buttons with the gear icon.

## Hardware connections
The SRS PS375 and PS370 communicate via a serial connection which is converted to ethernet however some models, such as the PS310, must instead use a GPIB to ethernet controller.

