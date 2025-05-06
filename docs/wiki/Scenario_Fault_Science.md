# Scenario - Device Fault in Science Mode

This scenario was developed to provide the user with an example of how the spacecraft can detect and recover from a fault. It also defines Action Point (AP), Watch Point (WP), and Real-Time Sequence (RTS), as well as giving examples of their use in the Limit Checker (LC) and Stored Command (SC) applications in cFS FSW.

## Learning Goals

By the end of this scenario, you should be able to:
* Walk through a fault scenario where the spacecraft recovers itself by power cycling
* Create a Watch Point
* Create an Action Point
* Create an RTS

## Prerequisites

Before running the scenario, ensure the following steps are completed:
* [Getting Started](./Getting_Started.md)
  * [Installation](./Getting_Started.md#installation)
  * [Running](./Getting_Started.md#running)
* No additional file changes or special setup is needed for this scenario.
* It is assumed for this scenario that the user understands how to command the Spacecraft with COSMOS, verify Telemetry via the Packet Viewer, and locate the FSW terminal window.

## Scenario Walkthrough
Before starting, make sure to launch NOS3 in the default misson configuration in your nos3-mission.xml (sc-mission-config.xml).

---
### Commanding the Spacecraft into Science mode.

* Once NOS3 is running and the FSW enters ADCS Mode 2 (Sunpoint Mode), we can command the spacecraft into Science mode.  This is shown below.

![Commanding Science Mode](./_static/scenario_fault_sample/setting_science_mode.png)

* This FSW Command will command the spacecraft into Science mode, thereby kicking off RTSs and enabling Action Points for this mode. For this scenario, we will be watching Action Point 36 which is activated under Science Mode.

* We will need to send the mgr_set_conus command with value 1. This will allow us to activate the Sample Device whenever the Spacecraft is both in science mode and over North America. This command is seen below.

![Enabling over North America](./_static/scenario_fault_sample/mgr_set_conus_1.png)

---
### Triggering a Simulated Fault with the Sample Device

* Now, you can either wait until your Spacecraft is passing over North America, which will enable the sample device, or you can enable it manually in order to speed up this Scenario Walkthrough.

![Sample Enable](./_static/scenario_fault_sample/sample_enable.png)

* Once the sample device is enabled you should see the sample device enabled event in cFS, displayed in your FSW window as pictured below. Also, note that AP 36 is activated.

![Sample Enable](./_static/scenario_fault_sample/sample_device_enabled_fsw_science.png)

* The sample simulator is now communicating with the sample application
  * The sample application has a scheduled rate at which it requests data from the device
* This is cool, but let's break some stuff
  * Change to the SIM_CMD_BUS_BRIDGE Target in the Command Sender
  * This interface enables us to command the simulators directly so we can see how flight software would respond
  * Let's send the SAMPLE_SIM_SET_STATUS command with a status value of 1
  * This command simulates the detection of a fault on the sample device

![Sample Set Sim Status](./_static/scenario_fault_sample/sample_device_status_1.png)

* Now, since we have simulated the detection of a fault on the sample device, Action Point 36 should be triggered, which will trigger RTS 36. This is pictured below.

![CFE ES Reset when triggered](./_static/scenario_fault_sample/cfe_es_reset.png)

* This AP will trigger an RTS that will cause a power cycle event on the spacecraft. Thus, FSW will reset and boot the spacecraft back into safe mode. You should see the STF splash screen come up again in your FSW window. as seen below:

![STF Splash Screen](./_static/scenario_fault_sample/stf1_splash_screen.png)

* It is important to understand that we have disabled Action Point 36 by default when booting into safe mode, but it is enabled when in Science mode. This is done to protect the spacecraft from resetting cyclically. 
* In order to avoid such cyclic resetting, it is important to disable Action Points like this in the appropriate RTS procedures.  This is especially true if a user were to add more APs, WPs, and RTSs like this in the future.


## How is this Fault Scenario Possible?

This Scenario is possible because of Action Points, Watch Points, and a new RTS 36. These concepts are described below.

---
### Creating an Action Point for cFS

An Action Point (AP) is used in Limit Checker (LC) and defines a specific telemetry parameter to monitor, along with the associated conditions (limits) on that parameter and actions to take when those limits are violated.

For this scenario, we created Action Point 36 and added it to the LC table found in **nos3/cfg/nos3_defs/tables/lc_def.adt.c**.  This is pictured below. Note that, by numbering convention, AP 36 is associated with RTS036. It is important to assign APs to the same RTS number for organization within cFS FSW.

![Action Point 36](./_static/scenario_fault_sample/ap_36.png)

---
### Creating a Watch Point for cFS

A Watch Point (WP) is used to monitor individual telemetry values and determine if they violate predefined conditions within the Limit Checker (LC) cFS application.

For this Scenario, we created WP 24 in the LC table found in **nos3/cfg/nos3_defs/tables/lc_def.wdt.c**. This was created to track the Device Status telemetry point found in Sample, shown below.

![Action Point 36](./_static/scenario_fault_sample/wp_24.png)

Note that the **watchpointoffset** is set equal to 29. This is because the telemetry point bit offset is 232. So 232/8 = 29, which equals the number of bytes needed for the watchpointoffset in our LC table.  The telemetry point bit offset can be found by selecting the hk tlm packet field in packet viewer (Sample_HK_TLM->Device_Status) -> selecting the field -> right clicking on the field -> selecting Details, as shown below.

![TLM details](./_static/scenario_fault_sample/Device_status_details_232.png)

---
### Creating an RTS

RTS stands for Real-Time Sequence. It is used by the Stored Command (SC) application to automate the execution of predefined command sequences on the spacecraft.

In this scenario, we created an RTS to execute if our AP 36 condition is true. According to that RTS036, if the sample device status telemetry point is nonzero and we are in science mode, the spacecraft will enter a power cycle event. This in turn resets the FSW as mentioned before. You can find the newly-created RTS 36 and review the RTS table in **nos3/cfs/nos3_defs/tables/sc_rts036.c**.

In that RTS table you will see the RTS perform the following tasks:
1. Disable the Instrument Application
2. Disable Instrument Switch on EPS
3. Restart cFS

Again, when we boot cFS after a reset we have AP 36 disabled, thus stopping the spacecraft from entering a FSW reset loop if the device is still broken. We also boot up into safe mode as another precaution.
Note that we disable AP 36 in the Science mode exit RTS (rts029) and we enable AP 36 in the Science mode boot up RTS (rts026). Both of these RTS tables can be found in **nos3/cfs/nos3_defs/tables/**.

---
### Conclusions

The user is now able to fault the sample device and have the spaceraft recover itself. Also, the user should have gained a better understanding of what an AP, WP, and RTS are and what they do in the cFS system.


