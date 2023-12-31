#!/bin/sh

major=$(uname -r | cut -d'.' -f1)
[ "x$major" = "x4" ] && exit 0

set -e

. /usr/lib/odroid-base/library.sh

case "$(odroid_model_simple)" in
	odroidn2 | odroidn2_plus)
		amixer  sset 'FRDDR_A SINK 1 SEL' 'OUT 1'  || true
		amixer sset 'FRDDR_A SRC 1 EN' 'on' || true
		amixer sset 'TDMOUT_B SRC SEL' 'IN 0' || true
		amixer sset 'TOHDMITX I2S SRC' 'I2S B' || true
		amixer sset 'TOHDMITX' 'on' || true

		amixer sset 'FRDDR_B SINK 1 SEL' 'OUT 2' || true
		amixer sset 'FRDDR_B SRC 1 EN' 'on' || true
		amixer sset 'TDMOUT_C SRC SEL' 'IN 1' || true
		amixer sset 'TOACODEC SRC' 'I2S C' || true
		amixer sset 'TOACODEC OUT EN' 'on' || true
		amixer sset 'TOACODEC Lane Select' '0' || true
		amixer sset 'ACODEC' '255'

		amixer sset 'FRDDR_C SINK 1 SEL' 'OUT 3' || true
		amixer sset 'FRDDR_C SRC 1 EN' 'on' || true
		amixer sset 'SPDIFOUT SRC SEL' 'IN 2' || true

		alsactl store
		;;

	odroidc4 | odroidhc4)
		amixer sset 'FRDDR_A SINK 1 SEL' 'OUT 1' || true
		amixer sset 'FRDDR_A SRC 1 EN' 'on' || true
		amixer sset 'TDMOUT_B SRC SEL' 'IN 0' || true
		amixer sset 'TOHDMITX I2S SRC' 'I2S B' || true
		amixer sset 'TOHDMITX' 'on' || true
		alsactl store
		;;
	*)
		;;
esac
