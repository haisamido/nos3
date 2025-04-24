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
![Scenario Demo - Make](./_static/scenario_demo/scenario_demo_make.png)

Then, launch NOS3 and open COSMOS:

![Scenario Demo - COSMOS](./_static/scenario_demo/scenario_demo_cosmos.png)

**_NOTE:_** COSMOS will automatically connect to the satellite, and assumes it always has communication with it.  This is not true for an actual satellite; in actuality, COSMOS would be running on a ground antenna and would therefore have to connect to the satellite and also have a fairly sharply limited duration of connection.  




THOUGHTS:

For this scenario, it really feels like the logical way to do things would be to make a script.
Maybe not a script which is Ruby, and runs in COSMOS, but one which runs alongside launch.sh and
does two things - firstly, it should launch COSMOS without connecting automatically, and then it
should close the connection (shut down the spacecraft, or some such similar thing) after however
long a pass would normally take.  Other than that, I do not think a script would be very necessary

