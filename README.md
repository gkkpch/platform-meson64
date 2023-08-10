
# platform-meson64
Volumio platform files for Amlogic S905Y2/ S905X3/ S922X and A311D (or other meson64) SBCs

Platform files are created using the armbian build system for kernel, u-boot, armbian-firmware.  
They have specific Volumio settings in armbianEnv.txt (read by the generic Armbian boot script for meson64 devices).


|Date|Author|Change
|---|---|---|
20230514|gkkpch|initial with Radxa Zero
20230607||Added Radxa Zero2
20230614||Modified radxa zero and zero2 dts to enable SPDIF
|||Created corresponding audio routing settings with a modified,  board-specific asound.state
|20230805|gkkpch|Added support for Odroid C4 and N2/N2+
|||Refactored platform-radxa to platform-meson64
|||Fixed mkplatform.sh text string, to reflect meson64, not just radxa
|20230810|gkkpch|Enabled HDMI/Lineout/SPDIF output options
|||Added support for Ugreen BT adapter, USB_DEVICE(0x0b05, 0x17dc)
|||Fixed an issue with missing firmware for RTL8761BUV
