Note that these are the recommended tasks and actions for submitting a pull request.  Please explore and ensure other use cases typically seen for this request have been covered.

### All Submissions:

* [ ] Have you followed the guidelines in our [Contributing](https://github.com/nasa/nos3/blob/main/CONTRIBUTING.md) document?
* [ ] Have you checked to ensure there aren't other open [Pull Requests](https://github.com/nasa/nos3/pulls) for the same update/change?

### New Feature Submissions:

* [ ] Does your submission pass tests?
  * [ ] Freshly provisioned VM via Vagrant
    * [ ] Default pathing
    * [ ] Shared Folder pathing
  * [ ] Direct clone into environment.

* [ ] No changes to ./cfg/nos3-mission.xml

* Confirm the following:
  * [ ] Flight Software loaded and running successfully
  * [ ] Spacecraft in 42 GUI points at sun and telemetry reports SVB (sun vector in body frame) X gets to a value of 1, others 0
  * Cryptolib Testing:
    * [ ] Cryptolib tab: run `tc`, send `CFE_ES_NOOP` and confim clear mode
    * [ ] Run `vcid 2`, send `CFE_ES_NOOP` and confirm encrypted.
    * [ ] Run `vcid 1`, send `CFE_ES_NOOP` and confirm clear mode again.

* Submodules Updated:
  * [ ] Submodule paths correct
  * [ ] Submodules merged appropriately or Pull requests created and completed PRIOR to this request.
    * [ ] Submodule merges completed PRIOR to merging this Pull Request.

### Changes to Core Features:

* [ ] Explanation added as to what your changes do and why they should be included

### How to test these changes?

* [ ] Explanation provided below detailing steps to test and validate changes

  > Describe testing steps here 

### Closing Tags
* [ ] Add any closing tags, or manually set this PR to close any related issue(s) that this PR resolves.
---

### Extra Considerations
#### COSMOS
* Change `./cfg/nos3-mission.xml` to COSMOS as the GSW
* Organize windows and start "COSMOS" from the NOS3 Launcher
* Open "Telemetry Grapher" with `./gsw/cosmos/config/tools/tlm_grapher/generic_adcs.txt` 
* Confirm
  * Flight software loaded and running successfully
  * Spacecraft in 42 GUI points at sun and telemetry grapher gets to SVB (sun vector in body frame) X gets to a value of 1, others 0
* Open "Test Runner" and click "Start" next to Mission_Test and wait for success
* Show CryptoLib tab, run `tc`, send a CFE_ES_NOOP and confirm clear mode, run `vcid 2`, send CFE_ES_NOOP and confirm encrypted, run `vcid 1`, send CFE_ES_NOOOP and confirm clear again
* In "Test Runner" run the "Start" for Mission_Test again and wait for success

#### F'
* Change `./cfg/nos3-mission.xml` to FSW / GSW both to fprime and use sc-fprime-config.xml
* Confirm
  * sampleSim.NOOP command and see it in sim
  * sampleSim.REQUEST_HOUSEKEEPING command, see it in sim, and see it in F' GDS event telemetry
  * generic_radio.REQUEST_HOUSEKEEPING command, see it in sim, and see it in F' GDS event telemetry
  * generic_star_tracker.NOOP command and see it in sim
  * generic_star_tracker.REQUEST_HOUSEKEEPING command, see it in sim, and see it in F' GDS event telemetry

--- 

## Test Checklist for Reviewers
* Provisioned default path
  - [ ] Default
  - [ ] COSMOS
  - [ ] F'
* Provisioned custom path
  - [ ] Default
  - [ ] COSMOS
  - [ ] F'
* Direct clone into Linux
  - [ ] Default
  - [ ] COSMOS
  - [ ] F'
- [ ] Documentation reviewed