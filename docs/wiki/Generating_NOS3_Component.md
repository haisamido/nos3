# Generating a New Component in NOS3: Quick Start Guide

NOS3 is organized around the foundational concept of a component.
The intent is that a spacecraft be made up of a core set of common functionality and then a custom set of components.  
Each component is represented by a FSW application which is placed in an `fsw` subdirectory of the component.
In order for the ground software to control the component application, a component has a collection of command and telemetry tables which are placed in a `gsw` subdirectory of the component.
In many cases (but not all), a component is a hardware component on the spacecraft and thus it is appropriate to have a NOS3 hardware simulator for the component which is placed in a `sims` subdirectory of the component.

Below is a step by step guide on how to generate a new component. Note that this guide follows the Sample component created in NOS3. It is up to the user to implement their own cFS app, and specific hardware model as they see fit for their application. The steps below are to guide a new user through the integration process of integrating a new component in NOS3.

## Step by Step Guide

1. First the user will want to run the generate_template.sh script found in the sample component. In a terminal change directory to components/sample/ and exectute as seen below. You will need to specify the name of your new component. Note, if the script is not executable simply enter the following command:
```
chmod +x generate_template.sh
```
![generate_template](./_static/adding_nos3_component/generate_template.png)

2. 

3. 




### Component Information

