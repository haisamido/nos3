# Scenario - Nominal Operations

This scenario was developed to explain and demonstrate the standard (nominal) operation of a satellite in orbit, using NASA Operational Simulator for Small Satellites (NOS3).
It demonstrates the use of the ground software (GSW) and the expected return telemetry, as well as making use of flight software (FSW) and simulators.

This scenario was last updated on INSERT_DATE_HERE and leveraged the `dev` branch at the time [TIME_HERE].

## Learning Goals

By the end of this scenario, you should be able to:
 * Connect to the simulated spacecraft at the beginning of a simulated pass
 * Send commands to change state or downlink data
 * Understand what portions of NOS3 would be accessible or visible in the context of a real satellite
 * Recognize anomalous telemetry
 * Take a simulated pass with NOS3

## Prerequisites

Before running the scenario, ensure the following steps are completed:
* [Getting Started](./Getting_Started.md)
  * [Installation](./Getting_Started.md#installation)
  * [Running](./Getting_Started.md#running)


## Walkthrough

With a terminal navigated to the top level of your NOS3 repository, run make clean and make:
 * `make clean`


 * `make`
![Scenario Nominal - Make](./_static/scenario_demo/scenario_demo_make.png)

Then, launch NOS3 and open COSMOS:

![Scenario Nominal - COSMOS](./_static/scenario_demo/scenario_demo_cosmos.png)

Open the script runner.  
In the script runner, perform File->Open... and choose the `gsw/cosmos/config/targets/MISSION/procedures/nominal_ops.rb` script.  
Press `Start`:

![Scenario Nominal - Nominal Pass](./_static/scenario_demo/scenario_nominal.png)

This script will approximate several aspects of taking a pass. 

**_NOTE:_** The user must select `go` in the script runner window when they are done commanding for the pass, since the script does not stop and disconnect COSMOS automatically.
Also, typical passes are of short duration (8-10 minutes) and it is up to the operator to keep track of time and when the pass ends.

### Connect to the Spacecraft

Before you can do anything else with the spacecraft, you must connect to it.  In NOS3 this is handled automatically, but with a real satellite this would have to be done first, in conjunction with the ground station and at the appropriate time for when your particular satellite would be in range.

### Confirm Telemetry is Nominal



### Send Commands

Once the spacecraft is known to be in a nominal state, the next step is to either send commands or to downlink data.  This scenario will provide an example of each.

For an example of sending a command, we will direct the spacecraft to enter science mode.  
The example spacecraft in NOS3 conducts science using the sample instrument when over the US; it has to be activated into science mode, however, to start doing this.  We will do so via COSMOS.  
First, navigate to the Command Sender and open the (INSERT_RELEVANT_THING).

### Downlink Data

Next we will go through an example of downlinking data.  This is the other thing likely to be done during a pass. 

Our example will be to downlink a picture from the Arducam, using the CAM_EXP_3 commands.  Typically this is how downlinking data will have to be done; some kind of command will trigger it.  






