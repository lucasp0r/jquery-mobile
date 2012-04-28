# Helper Variables
# The command to replace the @VERSION in the files with the actual version
HEAD_SHA = $(shell git log -1 --format=format:"%H")
VER = sed "s/v@VERSION/$$(git log -1 --format=format:"Git Build: SHA1: %H <> Date: %cd")/"
VER_MIN = "/*! jQuery Mobile v$$(git log -1 --format=format:"Git Build: SHA1: %H <> Date: %cd") jquerymobile.com | jquery.org/license */"
VER_OFFICIAL = $(shell cat version.txt)
SED_VER_REPLACE = 's/__version__/"${VER_OFFICIAL}"/g'
SED_VER_API = sed ${SED_VER_REPLACE}
SED_INPLACE_EXT = "whyunowork"
deploy: VER = sed "s/v@VERSION/${VER_OFFICIAL} ${HEAD_SHA}/"
deploy: VER_MIN = "/*! jQuery Mobile v${VER_OFFICIAL} ${HEAD_SHA} jquerymobile.com | jquery.org/license */"

# in build/bin/config.sh this setting will alter the variable definitions to match
# the changes for the deploy target in the makefile. temp solution
ARGS = IS_DEPLOY_TARGET=false
deploy: ARGS = IS_DEPLOY_TARGET=true

# The output folder for the finished files
OUTPUT = compiled

# The name of the files
NAME = jquery.mobile
BASE_NAME = jquery.mobile
THEME_FILENAME = jquery.mobile.theme
STRUCTURE = jquery.mobile.structure
deploy: NAME = jquery.mobile-${VER_OFFICIAL}
deploy: THEME_FILENAME = jquery.mobile.theme-${VER_OFFICIAL}
deploy: STRUCTURE = jquery.mobile.structure-${VER_OFFICIAL}

# The CSS theme being used
THEME = default

# Build Targets
# When no build target is specified, all gets ran
all: css js zip notify

clean:
	@@rm -rf ${OUTPUT}
	@@rm -rf tmp

# Create the output directory.
init:
	@@mkdir -p ${OUTPUT}

# Build and minify the CSS files
css: init
	@@${ARGS} bash build/bin/css.sh

# Build and minify the JS files
js: init
	@@${ARGS} bash build/bin/js.sh

docs: init js css
	@@${ARGS} bash build/bin/docs.sh

# Output a message saying the process is complete
notify: init
	@@echo "The files have been built and are in: " $$(pwd)/${OUTPUT}


# Zip up the jQm files without docs
zip: init css js
	@@${ARGS} bash build/bin/zip.sh

# -------------------------------------------------
#
# For jQuery Team Use Only
#
# -------------------------------------------------
# NOTE the clean (which removes previous build output) has been removed to prevent a gap in service
build_latest: css docs js zip
	@@${ARGS} bash build/bin/build_latest.sh

# Push the latest git version to the CDN. This is done on a post commit hook
deploy_latest:
	@@${ARGS} bash build/bin/deploy_latest.sh

# TODO target name preserved to avoid issues during refactor, latest -> deploy_latest
latest: build_latest deploy_latest

# Push the nightly backups. This is done on a server cronjob
deploy_nightlies:
	@@${ARGS} bash build/bin/deploy_nightlies.sh

# Deploy a finished release. This is manually done.
deploy: clean init css js docs zip
	@@${ARGS} bash build/bin/deploy.sh
