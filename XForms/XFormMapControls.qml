/* Copyright 2015 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtLocation 5.3
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Column {
    id: zoomButtons

    property Map map: null
    property XFormMapSettings mapSettings
    property XFormPositionSourceConnection positionSourceConnection

    property real size: 40
    property real zoomRatio: 2
    property real zoomStep: 0.5

    property color color: "#4C4C4C"
    property color disabledColor: "#E5E6E7"
    property color hoveredColor: "#E1F0FB"
    property color pressedColor: "#90CDF2"
    property color backgroundColor: "#F7F8F8"
    property color focusBorderColor: "#AADBFA"
    property color borderColor: "#CBCBCB"

    property alias fader: fader

    readonly property int buttonZoomIn: 0x01
    readonly property int buttonZoomOut: 0x02
    readonly property int buttonHome: 0x04
    readonly property int buttonPosition: 0x08

    property int buttons: buttonZoomIn + buttonZoomOut + buttonHome + buttonPosition

    spacing: 1

    //--------------------------------------------------------------------------

    QtObject {
        id: internal

        property real _size: size * AppFramework.displayScaleFactor
    }

    //--------------------------------------------------------------------------

    Fader {
        id: fader
    }

    //--------------------------------------------------------------------------

    Button {
        visible: buttons & buttonZoomIn && map
        width: internal._size
        height: width
        text: "+"
        style: buttonStyle
        enabled: map.zoomLevel < map.maximumZoomLevel

        onClicked: {
            fader.start();
            //map.zoomToScale (map.mapScale / zoomRatio);
            map.zoomLevel += zoomStep;
        }
    }

    //--------------------------------------------------------------------------

    Button {
        visible: buttons & buttonHome && map && mapSettings
        width: internal._size
        height: width
        iconSource: "images/home.png"
        style: buttonStyle

        onClicked: {
            fader.start();

            map.positionMode = 0;

            if (mapSettings.zoomLevel > 0) {
                console.log("Zoom to level:", mapSettings.zoomLevel);
                map.zoomLevel = mapSettings.zoomLevel;
            } else if (map.zoomLevel < mapSettings.defaultZoomLevel) {
                console.log("Zoom to default level:", mapSettings.defaultZoomLevel);
                map.zoomLevel = mapSettings.defaultPreviewZoomLevel;
            }

            var coord = QtPositioning.coordinate(mapSettings.latitude, mapSettings.longitude);
            if (coord.isValid) {
                console.log("Zoom to:", coord);
                map.center = coord;
            }
        }
    }

    //--------------------------------------------------------------------------

    Button {
        visible: buttons & buttonZoomOut && map
        width: internal._size
        height: width
        text: "-"
        style: buttonStyle
        enabled: map.zoomLevel > map.minimumZoomLevel

        onClicked: {
            fader.start();

            //            map.zoomToScale (map.mapScale * zoomRatio);
            map.zoomLevel -= zoomStep;
        }
    }

    //--------------------------------------------------------------------------

    Button {
        id: positionButton

        property bool isActive: map && positionSourceConnection && positionSourceConnection.active
        property int maxModes: 2 //map.positionDisplay.isCompassAvailable ? 4 : 3;

        visible: buttons & buttonPosition && map && positionSourceConnection && positionSourceConnection.valid

        width: internal._size
        height: width
        iconSource: isActive ? modeImage(map.positionMode) : "images/position-off.png"
        style: buttonStyle

        MouseArea {
            anchors.fill: parent

            onPressAndHold: {
                if (positionSourceConnection.active) {
                    positionSourceConnection.release();
                }

                fader.start();
            }

            onClicked: {
                if (positionSourceConnection.active) {
                    var mode = map.positionMode + 1;
                    if (mode >= positionButton.maxModes) {
                        map.positionMode = map.positionModeOn;
                        positionSourceConnection.release();
                    } else {
                        map.positionMode = mode;
                        var position = positionSourceConnection.positionSourceManager.positionSource.position;
                        if (position.longitudeValid && position.latitudeValid) {
                            map.center = position.coordinate;
                        }
                    }

                    //                    map.positionDisplay.mode = (map.positionDisplay.mode + 1) % positionButton.maxModes;
                } else {
                    map.positionMode = map.positionModeAutopan;
                    positionSourceConnection.activate();
                }

                fader.start();
            }
        }

        function modeImage(mode) {
            switch (mode) {
            case -1 :
                return "images/position-off.png";

            case 0 :
                return "images/position-on.png";

            case 1 :
                return "images/position-autopan.png";

            case 2 :
                return "images/position-navigation.png";

            case 3 :
                return "images/position-compass.png"
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: buttonStyle
        ButtonStyle {

            label: Item {
                Image {
                    anchors.centerIn: parent
                    width: internal._size * 0.8
                    height: width
                    source: control.iconSource
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    anchors.centerIn: parent
                    color: control.enabled ? zoomButtons.color : disabledColor
                    text: control.text
                    font {
                        pixelSize: internal._size * 0.75
                        bold: true
                    }
                }
            }

            background: Rectangle {
                color: control.hovered ?  hoveredColor : (control.pressed ? pressedColor : backgroundColor)
                border {
                    color: control.activeFocus ? focusBorderColor : borderColor
                    width: control.activeFocus ? 2 : 1
                }
                radius: 4
                implicitWidth: 40
                implicitHeight: 40
            }

            Connections {
                target: control

                onPressedChanged: {
                    if (control.pressed) {
                        fader.start();
                    }
                }

                onHoveredChanged: {
                    if (control.hovered) {
                        fader.stop();
                    } else {
                        fader.start();
                    }
                }
            }
        }
    }
}
