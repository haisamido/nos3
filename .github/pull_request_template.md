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

* Submodules Updated:
  * [ ] Submodule paths correct
  * [ ] Submodules merged appropriately into submodule dev branches, or Pull requests created and completed PRIOR to this request.

    > Describe submodules modified here.

### Changes to Core Features:

* [ ] Explanation added as to what your changes do and why they should be included

  > Describe changes here

### How to test these changes?

* [ ] Explanation provided below detailing steps to test and validate changes

  > Describe testing steps here 

### Closing Tags
* [ ] Add any closing tags, or manually set this PR to close any related issue(s) that this PR resolves.

--- 

## Test Checklist for Reviewers
* Provisioned default path (ensure your update doesn't break other configurations)
  - [ ] Default NOS
  - [ ] COSMOS
  - [ ] F'

* [ ] Documentation reviewed

* [ ] Validate destination branch after merge.