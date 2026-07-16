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

# Check against official devices JSON
AETHERIA_OFFICIAL_JSON := $(shell /usr/bin/curl -sf --connect-timeout 5 https://raw.githubusercontent.com/AetheriaOS-Devices/aetheria_official_devices/aetheria-1.0/$(AETHERIA_BUILD).json)

AETHERIA_CHECK_USER := $(shell echo '$(AETHERIA_OFFICIAL_JSON)' | python3 -c "import sys,json; d=json.load(sys.stdin); print('match') if d.get('github_username')=='$(AETHERIA_GITHUB_USER)' else print('nomatch')" 2>/dev/null)

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
PRODUCT_PRODUCT_PROPERTIES += \
    ro.aetheria.version=$(AETHERIA_VERSION) \
    ro.aetheria.display.version=$(AETHERIA_DISPLAY_VERSION) \
    ro.aetheria.build.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR) \
    ro.aetheria.releasetype=$(AETHERIA_BUILDTYPE) \
    ro.aetheria.maintainer=$(AETHERIA_MAINTAINER) \
    ro.aetheria.buildtype=$(AETHERIA_BUILDTYPE)
