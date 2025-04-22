# STF - Quick Look

The Simulation To Flight (STF) mission has a need for a quick look mission document for spacecraft operators.
This contains all relevant links to documentation and code needed to quickly get to where the necessary information resides.

## Power

The Electrical Power System (EPS) has a number of switches for various components to enable power savings and cycling across the spacecraft.
The EPS switches are linked to the following:
* Switch 0 - Sample Instrument
* Switch 1 - Star Tracker
* Switch 2 - Unassigned
* Switch 3 - Unassigned
* Switch 4 - Unassigned
* Switch 5 - Unassigned
* Switch 6 - Unassigned
* Switch 7 - Unassigned

## Data

Data generation and storage are vital.
A balance must be between quickly identifying anomalies and maximizing science data collection.

### Schedule

The core Flight System (cFS) schedule (SCH) application is used to request data production or initiate checks at a set frequency.
The default and selected frequency for the STF mission is 100Hz.
A single command can occur during each of these 100 slots.
* [./cfg/nos3_defs/tables/sch_def_msgtbl.c](../../cfg/nos3_defs/tables/sch_def_msgtbl.c)
  * Pre-defined commands that can be used in the actual schedule
  * This includes full command definitions and no logic to change them without a new table being uploaded
* [./cfg/nos3_defs/tables/sch_def_schtbl.c](../../cfg/nos3_defs/tables/sch_def_schtbl.c)
  * 100 schedule slots, each with its own execution window in the 100Hz
  * Defines the frequency in seconds, offset to sending window in seconds to allow balancing of schedule, and command references
    * Sending window example: assuming two packets at a five second frequency, one could execute at 0 and other at 2 seconds into the window
  * A request may occur in multiple slots, typically done to be faster than the 1Hz default maximum frequency

### Data Storage (DS)

The data storage application simply subscribes to messages on the software bus and has the ability to down sample them as desired.
This does not capture simply prints to the console, but all telemetry published and available from each component including log messages.
* [./cfg/nos3_defs/tables/ds_file_tbl.c](../../cfg/nos3_defs/tables/ds_file_tbl.c)
  * Configure the files to be created detailing naming convention (time or count), location in memory, maximum size and age
* [./cfg/nos3_defs/tables/ds_filter_tbl.c](../../cfg/nos3_defs/tables/ds_filter_tbl.c)
  * Ideally has an index for each packet produced by the spacecraft
  * Provides details for down sample (if desired) for each defined file type

For STF, the ADCS and component HK data is down sampled to be stored at 0.1Hz while the all science data and console logs are stored.
All data is stored in a single file type for simplicity in operations and enabling data in time to be captured together.

## Fault Detection and Correction (FDC)

FDC is performed in cFS by pairing up two different applications.
These are the Limit Checker (LC) and the Stored Command (SC).

### Limit Checker (LC)

The LC application enables monitoring of specific bits within packets to take action on, these are configured in two tables:
* [./cfg/nos3_defs/tables/lc_def_adt.c](../../cfg/nos3_defs/tables/lc_def_adt.c)
  * The actionpoint (AP) definition table (ADT) defines the equations used to evaluate watch point (WP) states, and the actions to be taken
  * The action to be taken is stored in a Relative Time Sequence (RTS) and maintained by the SC application
* [./cfg/nos3_defs/tables/lc_def_wdt.c](../../cfg/nos3_defs/tables/lc_def_wdt.c)
  * The WP definition table (WDT) defines the data to be evaluated

### Stored Command (SC)

Two SC types exist:
* [./cfg/nos3_defs/tables/sc_ats1.c](../../cfg/nos3_defs/tables/sc_ats1.c)
  * Absolute Time Sequence (ATS)
  * Each command is set to execute at a pre-determined point in time
  * Avoided in the STF mission as we are handling the mode transitions on-board the vehicle
* [./cfg/nos3_defs/tables/sc_rts001.c](../../cfg/nos3_defs/tables/sc_rts001.c)
  * Relative Time Sequence (RTS)
  * This is used to control the spacecraft through mode transitions, start of pass, and general setup/teardown/maintenance command sequences

A summary of the current RTSs for the STF mission are captured below:
* [sc_rts001.c](https://github.com/nasa/nos3/blob/dev/cfg/nos3_defs/tables/sc_rts001.c) - Power On Reset (POR)
  * Enable DS
  * Enable debug interface
  * Enable RTS 3-64
  * Enable LC
  * Start RTS 3 (Safe Mode)
* [sc_rts003.c](https://github.com/nasa/nos3/blob/dev/cfg/nos3_defs/tables/sc_rts003.c) - Goto Safe Mode
  * Enable CSS
  * Enable FSS
  * Enable IMU
  * Enable MAG
  * Enable Torquers
  * Enable GPS
  * Set ADCS To SUNSAFE_MODE
* [sc_rts025.c](https://github.com/nasa/nos3/blob/dev/cfg/nos3_defs/tables/sc_rts025.c) - Enable Science Mode
  * Disable AP25
  * Set science mode in MGR
* [sc_rts026.c](https://github.com/nasa/nos3/blob/dev/cfg/nos3_defs/tables/sc_rts026.c) - Science, Enable
  * Enable RTS27 - RTS32
  * Reset AP27 - AP32
  * Set AP27 - AP32 active
* [sc_rts027.c](https://github.com/nasa/nos3/blob/dev/cfg/nos3_defs/tables/sc_rts027.c) - Science, Low power pause
  * Lower power in MGR, SS_NO_SCIENCE_LOW_POWER
  * Disable AP30 - AP35
  * Disable instrument application
  * Reset AP28
  * Set AP28 active
* [sc_rts028.c](https://github.com/nasa/nos3/blob/dev/cfg/nos3_defs/tables/sc_rts028.c) - Science, Recharged resuming
  * Resume science in MGR, SS_NO_SCIENCE_RECHARGED
  * Disable AP28
  * Reset AP27 - AP32
  * Set AP27 - AP32 active
* [sc_rts029.c](https://github.com/nasa/nos3/blob/dev/cfg/nos3_defs/tables/sc_rts029.c) - Science, Exit
  * Stop science in MGR, SS_EXITED_SCIENCE_MODE
  * Disable AP27 - AP35
  * Disable instrument application
  * Reset AP26
  * Set AP26 active
* [sc_rts030.c](https://github.com/nasa/nos3/blob/dev/cfg/nos3_defs/tables/sc_rts030.c) - Science, Over AK
  * Start science in MGR, SS_SCIENCE_OVER_AK
  * Increment science pass counter
  * Enable instrument application
  * Reset AP33
  * Set AP33 active 
* [sc_rts031.c](https://github.com/nasa/nos3/blob/dev/cfg/nos3_defs/tables/sc_rts031.c) - Science, Over CONUS
  * Start science in MGR, SS_SCIENCE_OVER_CONUS
  * Increment science pass counter
  * Enable instrument application
  * Reset AP34
  * Set AP34 active
* [sc_rts032.c](https://github.com/nasa/nos3/blob/dev/cfg/nos3_defs/tables/sc_rts032.c) - Science, Over HI
  * Start science in MGR, SS_SCIENCE_OVER_HI
  * Increment science pass counter
  * Enable instrument application
  * Reset AP35
  * Set AP35 active
* [sc_rts033.c](https://github.com/nasa/nos3/blob/dev/cfg/nos3_defs/tables/sc_rts033.c) - Science Idle, Left AK
  * Stop science in MGR, SS_NO_SCIENCE_LEFT_AK
  * Disable instrument application
  * Reset AP31
  * Set AP31 active
* [sc_rts034.c](https://github.com/nasa/nos3/blob/dev/cfg/nos3_defs/tables/sc_rts034.c) - Science Idle, Left CONUS
  * Stop science in MGR, SS_NO_SCIENCE_LEFT_CONUS
  * Disable instrument application
  * Reset AP31
  * Set AP31 active
* [sc_rts035.c](https://github.com/nasa/nos3/blob/dev/cfg/nos3_defs/tables/sc_rts035.c) - Science Idle, Left HI
  * Stop science in MGR, SS_NO_SCIENCE_LEFT_HI
  * Disable instrument application
  * Reset AP31
  * Set AP31 active

Note that if an RTS number is not in the above list, it will use the default table available which typically performs no operation (NOOP) commands.

## Standard Operating Procedures

TBD

### Pass Logs

### Standard Pass

### Patching
