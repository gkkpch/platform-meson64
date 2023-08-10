MODEL=$(cat /etc/os-release | grep VOLUMIO_DEVICENAME | cut -d'"' -f2)

set -e

case $MODEL in
  "Odroid-N2")
	amixer -c 0 sset 'FRDDR_A SINK 1 SEL' 'OUT 1'  || true
	amixer -c 0 sset 'FRDDR_A SRC 1 EN' 'on' || true
	amixer -c 0 sset 'TDMOUT_B SRC SEL' 'IN 0' || true
	amixer -c 0 sset 'TOHDMITX I2S SRC' 'I2S B' || true
	amixer -c 0 sset 'TOHDMITX' 'on' || true

	amixer -c 0 sset 'FRDDR_B SINK 1 SEL' 'OUT 2' || true
	amixer -c 0 sset 'FRDDR_B SRC 1 EN' 'on' || true
	amixer -c 0 sset 'TDMOUT_C SRC SEL' 'IN 1' || true
	amixer -c 0 sset 'TOACODEC SRC' 'I2S C' || true
	amixer -c 0 sset 'TOACODEC OUT EN' 'on' || true
	amixer -c 0 sset 'TOACODEC Lane Select' '0' || true
	amixer -c 0 sset 'ACODEC' '200'

	amixer -c 0 sset 'FRDDR_C SINK 1 SEL' 'OUT 3' || true
	amixer -c 0 sset 'FRDDR_C SRC 1 EN' 'on' || true
	amixer -c 0 sset 'SPDIFOUT SRC SEL' 'IN 2' || true

	alsactl store
  	;;

  "Odroid-C4")
	amixer sset 'FRDDR_A SINK 1 SEL' 'OUT 1' || true
	amixer sset 'FRDDR_A SRC 1 EN' 'on' || true
	amixer sset 'TDMOUT_B SRC SEL' 'IN 0' || true
	amixer sset 'TOHDMITX I2S SRC' 'I2S B' || true
	amixer sset 'TOHDMITX' 'on' || true
	alsactl store
  	;;

  "Radxa Zero" | "Radxa Zero2")

	;;
  *)
  ;;
esac

