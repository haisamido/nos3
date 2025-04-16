#
# Top Level Mission Makefile
#
.PHONY: help

BUILDTYPE ?= debug
INSTALLPREFIX ?= exe
FSWBUILDDIR ?= $(CURDIR)/fsw/build
GSWBUILDDIR ?= $(CURDIR)/gsw/build
SIMBUILDDIR ?= $(CURDIR)/sims/build
COVERAGEDIR ?= $(CURDIR)/fsw/build/amd64-posix/default_cpu1

export SYSTEM_TEST_FILE_PATH = /scripts/gsw/system_test.rb

export CFS_APP_PATH = ../components
export MISSION_DEFS = ../cfg/build/
export MISSIONCONFIG = ../cfg/build/nos3


# The "prep" step requires extra options that are specified via environment variables.
# Certain special ones should be passed via cache (-D) options to CMake.
# These are only needed for the "prep" target but they are computed globally anyway.
PREP_OPTS :=

ifneq ($(INSTALLPREFIX),)
PREP_OPTS += -DCMAKE_INSTALL_PREFIX=$(INSTALLPREFIX)
endif

ifneq ($(VERBOSE),)
PREP_OPTS += --trace
endif

ifneq ($(BUILDTYPE),)
PREP_OPTS += -DCMAKE_BUILD_TYPE=$(BUILDTYPE)
endif


# The "LOCALTGTS" defines the top-level targets that are implemented in this makefile
# Any other target may also be given, in that case it will simply be passed through.
LOCALTGTS := all checkout clean clean-fsw clean-sim clean-gsw config debug fsw gcov gsw launch log prep sim stop stop-gsw uninstall
OTHERTGTS := $(filter-out $(LOCALTGTS),$(MAKECMDGOALS))

# As this makefile does not build any real files, treat everything as a PHONY target
# This ensures that the rule gets executed even if a file by that name does exist
.PHONY: $(LOCALTGTS) $(OTHERTGTS)

#
# Commands
#
all: ## Build everything: config, fsw, sim, gsw
	$(MAKE) config
	$(MAKE) fsw
	$(MAKE) sim
	$(MAKE) gsw

build-cryptolib: ## Build CryptoLib Component
	mkdir -p $(GSWBUILDDIR)
	cd $(GSWBUILDDIR) && cmake $(PREP_OPTS) -DSUPPORT=1 ../../components/cryptolib
	$(MAKE) --no-print-directory -C $(GSWBUILDDIR)

build-fsw: ## Build the flight software (cFS or F')
ifeq ($(FLIGHT_SOFTWARE), fprime)
	cd fsw/fprime/fprime-nos3 && fprime-util generate && fprime-util build
else
	mkdir -p $(FSWBUILDDIR)
	cd $(FSWBUILDDIR) && cmake $(PREP_OPTS) ../cfe
	$(MAKE) --no-print-directory -C $(FSWBUILDDIR) mission-install
endif

build-sim: ## Build Simulator
	mkdir -p $(SIMBUILDDIR)
	cd $(SIMBUILDDIR) && cmake -DCMAKE_INSTALL_PREFIX=$(SIMBUILDDIR) ..
	$(MAKE) --no-print-directory -C $(SIMBUILDDIR) install

build-test: ## Build unit tests
ifeq ($(FLIGHT_SOFTWARE), fprime)
	# TODO
else
	mkdir -p $(FSWBUILDDIR)
	cd $(FSWBUILDDIR) && cmake $(PREP_OPTS) -DENABLE_UNIT_TESTS=true ../cfe
	$(MAKE) --no-print-directory -C $(FSWBUILDDIR) mission-install
endif

checkout: ## Run a checkout application (may require reconfiguration)
	./scripts/checkout.sh

#This could currently break if not using COSMOS in the config.
ci-launch: ## Headless Launch for System Testing
	@export SYSTEM_TEST_FILE_PATH=$(SYSTEM_TEST_FILE_PATH) && \
	./scripts/ci_launch.sh && \
	./scripts/system_tests.sh && \
	./scripts/stop.sh

#This could currently break if not using COSMOS in the config.
system-tests: ## System Testing with GUI
	@export SYSTEM_TEST_FILE_PATH=../..$(SYSTEM_TEST_FILE_PATH) && \
	./cfg/build/launch.sh && \
	./scripts/system_tests.sh

#Be sure that your nos3-mission.xml has been set to YAMCS
yamcs-operator:  ## Launch as a YAMCS operator viewpoint
	@export SYSTEM_TEST_FILE_PATH=$(SYSTEM_TEST_FILE_PATH) && \
	./scripts/ci_launch.sh --use-yamcs

#Be sure that your nos3-mission.xml has been set to COSMOS
cosmos-operator: ## Launch as a COSMOS operator viewpoint
	@export SYSTEM_TEST_FILE_PATH=../..$(SYSTEM_TEST_FILE_PATH) && \
	./scripts/ci_launch.sh --use-cosmos-gui 

clean: ## Clean all build files and configurations
	$(MAKE) clean-fsw
	$(MAKE) clean-sim
	$(MAKE) clean-gsw
	rm -rf cfg/build

clean-fsw: ## Clean only flight software build artifacts
	rm -rf cfg/build/nos3_defs
	rm -rf fsw/build
	rm -rf fsw/fprime/fprime-nos3/build-artifacts
	rm -rf fsw/fprime/fprime-nos3/build-fprime-automatic-native
	rm -rf fsw/fprime/fprime-nos3/fprime-venv

clean-sim: ## Clean only simulator build artifacts
	rm -rf sims/build

clean-gsw: ## Clean only GSW build artifacts
	rm -rf gsw/build
	rm -rf gsw/cosmos/build
	rm -rf /tmp/nos3

config: ## Run configuration setup
	./scripts/cfg/config.sh

debug: ## Launch the debug container terminal
	./scripts/debug.sh

fsw:  ## Build Flight Software binaries
	./cfg/build/fsw_build.sh

gcov: ## Build Code Coverage results
	cd $(COVERAGEDIR) && ctest -O ctest.log
	lcov -c --directory . --output-file $(COVERAGEDIR)/coverage.info
	genhtml $(COVERAGEDIR)/coverage.info --output-directory $(COVERAGEDIR)/results

gsw: ## Build Ground Software binaries
	./scripts/gsw/build_cryptolib.sh
	./cfg/build/gsw_build.sh

help: ## Display this help message
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

igniter: ## Launch Configuration GUI Igniter
	./scripts/cfg/igniter_launch.sh

launch: ## Launch NOS3 System
	./cfg/build/launch.sh

log: ## Log outputs
	./scripts/log.sh

prep: ## Prepare full development enviornment
	./scripts/cfg/prepare.sh

prep-gsw: ## Prepare Ground Software
	./scripts/cfg/prep_gsw.sh

prep-sat: ## Prepare Satelite IP Routes
	./scripts/cfg/prep_sat.sh

sim: ## Build Sims
	./scripts/build_sim.sh

start-gsw: ## Launch Ground Software
	./scripts/gsw/launch_gsw.sh

start-sat: ## Satellite Launch
	./scripts/fsw/launch_sat.sh

stop: ## Stop entire system
	./scripts/stop.sh

stop-gsw: ## Stop Ground Sfotware
	./scripts/gsw/stop_gsw.sh

test-fsw: ## Test Flight Software 
	cd $(COVERAGEDIR) && ctest --output-on-failure -O ctest.log

uninstall: ## Remove all build artifacts
	$(MAKE) clean
	./scripts/cfg/uninstall.sh