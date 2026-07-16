PRODUCT_VERSION_MAJOR = 1
PRODUCT_VERSION_MINOR = 0

AETHERIA_BUILD := $(TARGET_DEVICE)

ifeq ($(AETHERIA_VERSION_APPEND_TIME_OF_DAY),true)
    AETHERIA_BUILD_DATE := $(shell date -u +%Y%m%d_%H%M%S)
else
    AETHERIA_BUILD_DATE := $(shell date -u +%Y%m%d)
endif

# Get GitHub username via SSH (non-interaktif, ada timeout)
AETHERIA_GITHUB_USER := $(shell ssh -T -o BatchMode=yes -o ConnectTimeout=5 git@github.com 2>&1 | /usr/bin/grep -oP '(?<=Hi ).*(?=!)')

AETHERIA_YELLOW := \033[1;33m
AETHERIA_NC := \033[0m

# Check against official devices JSON (repo is private, fetch via SSH git clone)
AETHERIA_CLONE_STATUS := $(shell rm -rf /tmp/aetheria_official_devices 2>/dev/null; \
    git clone --quiet --depth 1 --branch aetheria-1.0 git@github.com:AetheriaOS-Devices/aetheria_official_devices.git /tmp/aetheria_official_devices >/dev/null 2>&1; \
    echo $$?)

AETHERIA_OFFICIAL_JSON := $(shell cat /tmp/aetheria_official_devices/$(AETHERIA_BUILD).json 2>/dev/null)

AETHERIA_CHECK_USER := $(shell echo '$(AETHERIA_OFFICIAL_JSON)' | python3 -c "import sys,json; d=json.load(sys.stdin); print('match') if d.get('github_username')=='$(AETHERIA_GITHUB_USER)' else print('nomatch')" 2>/dev/null)

ifneq ($(AETHERIA_CLONE_STATUS),0)
    $(warning $(shell printf "$(AETHERIA_YELLOW)WARNING$(AETHERIA_NC): AetheriaOS failed to clone aetheria_official_devices (check SSH keys/connections) - this build will be marked as UNOFFICIAL"))
else
    ifeq ($(strip $(AETHERIA_OFFICIAL_JSON)),)
        $(warning $(shell printf "$(AETHERIA_YELLOW)WARNING$(AETHERIA_NC): AetheriaOS could not find file $(AETHERIA_BUILD).json in the official devices repo - this build will be marked UNOFFICIAL"))
    endif
endif

ifeq ($(AETHERIA_CHECK_USER), match)
    AETHERIA_BUILDTYPE := OFFICIAL
    AETHERIA_MAINTAINER := $(shell echo '$(AETHERIA_OFFICIAL_JSON)' | python3 -c "import sys,json; print(json.load(sys.stdin)['maintainer'])" 2>/dev/null)
else
    AETHERIA_BUILDTYPE := UNOFFICIAL
    AETHERIA_MAINTAINER := Unknown
endif

# Maintainer avatar
ifeq ($(AETHERIA_BUILDTYPE), OFFICIAL)
    PRODUCT_PACKAGES += AetheriaMaintainer$(AETHERIA_BUILD)
endif

AETHERIA_EXTRAVERSION :=
ifeq ($(AETHERIA_BUILDTYPE), UNOFFICIAL)
    ifneq ($(TARGET_UNOFFICIAL_BUILD_ID),)
        AETHERIA_EXTRAVERSION := -$(TARGET_UNOFFICIAL_BUILD_ID)
    endif
endif

AETHERIA_VERSION_SUFFIX := $(AETHERIA_BUILD_DATE)-$(AETHERIA_BUILDTYPE)$(AETHERIA_EXTRAVERSION)-$(AETHERIA_BUILD)

# Internal version
AETHERIA_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(AETHERIA_VERSION_SUFFIX)
# Display version
AETHERIA_DISPLAY_VERSION := $(PRODUCT_VERSION_MAJOR)-$(AETHERIA_VERSION_SUFFIX)

# AetheriaOS version properties
PRODUCT_SYSTEM_PROPERTIES += \
    ro.aetheria.version=$(AETHERIA_VERSION) \
    ro.aetheria.display.version=$(AETHERIA_DISPLAY_VERSION) \
    ro.aetheria.build.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR) \
    ro.aetheria.releasetype=$(AETHERIA_BUILDTYPE) \
    ro.aetheria.maintainer=$(AETHERIA_MAINTAINER) \
    ro.aetheria.buildtype=$(AETHERIA_BUILDTYPE)
