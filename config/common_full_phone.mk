# Inherit mobile full common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_mobile_full.mk)

# Enable support of one-handed mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_one_handed_mode?=true

PRODUCT_PRODUCT_PROPERTIES += \
    ro.setupwizard.enterprise_mode=1 \
    setupwizard.feature.baseline_setupwizard_enabled=true \
    setupwizard.feature.day_night_mode_enabled=true \
    setupwizard.feature.portal_notification=true \
    setupwizard.feature.enable_quick_start_flow=true \
    setupwizard.feature.lifecycle_refactoring=true \
    setupwizard.feature.notification_refactoring=true \
    setupwizard.feature.show_pixel_tos=true \
    setupwizard.feature.joined_up_loading=true \
    setupwizard.theme=glif_expressive

$(call inherit-product, vendor/lineage/config/telephony.mk)
$(call inherit-product-if-exists, vendor/pixel/clocks/products/clocks.mk)
$(call inherit-product-if-exists, vendor/pixel/themepicker/products/themepicker.mk)
