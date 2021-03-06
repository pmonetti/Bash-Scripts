#! /bin/bash

# The utils.sh script is required to use the following functions:
# get_linux_version_id
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/utils.sh

TMP_PANEL_NAME='temppanel'
TMP_PANEL_DIR=$TMP_PANEL_NAME
TMP_LAUNCHER_DIR=$TMP_PANEL_DIR'/launcher-9'
CONFIG_FILE_PATH=$TMP_PANEL_DIR"/config.txt"
LAUNCHER_DESKTOP_FILE=$TMP_LAUNCHER_DIR"/14822583191.desktop"
TAR_FILE=$TMP_PANEL_NAME.tar.bz2

mkdir -p $TMP_LAUNCHER_DIR

cat << EOF >> $CONFIG_FILE_PATH
/configver 2
/panels [<0>]
/panels/panel-0/autohide-behavior uint32 0
/panels/panel-0/background-alpha uint32 80
/panels/panel-0/background-color [<uint32 11653>, <uint32 11797>, <uint32 20656>, <uint32 65535>]
/panels/panel-0/background-style uint32 1
/panels/panel-0/enter-opacity uint32 100
/panels/panel-0/leave-opacity uint32 100
/panels/panel-0/length uint32 100
/panels/panel-0/length-adjust true
/panels/panel-0/mode uint32 0
/panels/panel-0/plugin-ids [<1>, <2>, <3>, <22>, <4>, <21>, <5>, <12>, <8>, <18>, <10>, <14>, <11>]
/panels/panel-0/position 'p=6;x=0;y=0'
/panels/panel-0/position-locked true
/panels/panel-0/size uint32 24
/panels/panel-0/span-monitors false
/plugins/plugin-1 'whiskermenu'
/plugins/plugin-10 'xfce4-notes-plugin'
/plugins/plugin-11 'actions'
/plugins/plugin-11/appearance uint32 0
/plugins/plugin-11/items [<'+lock-screen'>, <'-switch-user'>, <'-separator'>, <'-suspend'>, <'-hibernate'>, <'-separator'>, <'+shutdown'>, <'+restart'>, <'-separator'>, <'-logout'>, <'-logout-dialog'>]
/plugins/plugin-12 'weather'
/plugins/plugin-14 'showdesktop'
/plugins/plugin-18 'separator'
/plugins/plugin-18/style uint32 3
/plugins/plugin-2 'tasklist'
/plugins/plugin-2/flat-buttons true
/plugins/plugin-2/show-handle false
/plugins/plugin-2/show-labels true
/plugins/plugin-2/sort-order uint32 1
/plugins/plugin-21 'systemload'
/plugins/plugin-22 'pulseaudio'
/plugins/plugin-22/enable-keyboard-shortcuts true
/plugins/plugin-3 'separator'
/plugins/plugin-3/expand true
/plugins/plugin-3/style uint32 0
/plugins/plugin-4 'systray'
/plugins/plugin-4/names-visible [<'thunar'>, <'vlc'>, <'redshift-gtk'>, <'red'>, <'notificador de actualizaciones'>, <'terminal de xfce'>, <'networkmanager applet'>, <'task manager'>, <'guake'>, <'skype'>, <'network'>, <'fluxgui'>, <'blueman-applet'>, <'notas'>, <'update-notifier'>, <'miniaplicación gestor de la red'>, <'xfce4-power-manager'>, <'scp-dbus-service.py'>, <'javaembeddedframe'>, <'desplegar terminal'>]
/plugins/plugin-4/show-frame false
/plugins/plugin-4/size-max uint32 22
/plugins/plugin-5 'power-manager-plugin'
/plugins/plugin-8 'clock'
/plugins/plugin-8/digital-format '%d %b, %H:%M'
EOF

cat << EOF >> $LAUNCHER_DESKTOP_FILE
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=PulseAudio Volume Control
Name[es]=Control de Volumen de PulseAudio
GenericName=Volume Control
GenericName[es]=Control de Volumen
Comment=Adjust the volume level
Comment[es]=Ajustar el nivel de volumen
Exec=pavucontrol
Icon=multimedia-volume-control
StartupNotify=true
Type=Application
Categories=AudioVideo;Audio;Mixer;GTK;
X-XFCE-Source=file:///usr/share/applications/pavucontrol.desktop
EOF

cd $TMP_PANEL_DIR && tar -zcvf ../$TAR_FILE * > /dev/null && cd --

LINUX_VERSION_ID=$(get_linux_version_id)

if [ "$LINUX_VERSION_ID" = "16.04" ] ; then
	python3 /usr/share/xfpanel-switch/xfpanel-switch/panelconfig.py load $TAR_FILE
elif [ "$LINUX_VERSION_ID" = "18.04" ] ; then
	xfpanel-switch load $TAR_FILE
else
	echo "Unsupported linux version:" $LINUX_VERSION_ID
fi

rm -rf $TMP_PANEL_DIR
rm -rf $TAR_FILE

