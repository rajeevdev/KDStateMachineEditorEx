/*
  This file is part of the KDAB State Machine Editor Library.

  SPDX-FileCopyrightText: 2014-2021 Klarälvdalens Datakonsult AB, a KDAB Group company <info@kdab.com>
  Author: Kevin Funk <kevin.funk@kdab.com>

  SPDX-License-Identifier: LGPL-2.1-only OR LicenseRef-KDAB-KDStateMachineEditor

  Licensees holding valid commercial KDAB State Machine Editor Library
  licenses may use this file in accordance with the KDAB State Machine Editor
  Library License Agreement provided with the Software.

  Contact info@kdab.com if any conditions of this licensing are not clear to you.
*/

import QtQuick 2.0

import com.kdab.kdsme 1.0 as KDSME

import "qrc:///kdsme/qml/util/"

Item {
    id: root

    property var control
    property bool resizing: false

    signal clicked
//    signal doubleClicked

    property int rulersSize: 10

    MouseArea {
        id: mouseArea
//        hoverEnabled: true
        anchors.fill: parent

        drag.target: control.element.flags & KDSME.Element.ElementIsDragEnabled ?
                         parent :
                         null

        property variant previousPosition

        onClicked: {
            scene.currentItem = control.element;
            root.clicked();
        }
//        onDoubleClicked: {
//            root.doubleClicked();
//        }

        onPressed: {
            previousPosition = Qt.point(mouseX, mouseY)
        }

        onPositionChanged: {
            if (pressedButtons == Qt.LeftButton) {
                var dx = mouseX - previousPosition.x
                var dy = mouseY - previousPosition.y
                move(dx, dy)
            }
        }
    }

    Rectangle {
        id: rect

        anchors.fill: parent
        radius: 5

        border {
            color: Theme.currentTheme.highlightBackgroundColor
            width: 2
        }
        color: "transparent"

        visible: control ?
                     control.element.flags & KDSME.Element.ElementIsSelectable && control.element.selected :
                     false


        Rectangle {
            width: rulersSize
            height: rulersSize
            color:  "yellow"
            anchors.top: parent.top
            anchors.left: parent.left


            MouseArea {
                id: mouseAreaTopLeft
                anchors.fill: parent
                hoverEnabled: true
                drag.target: parent

                property variant previousPosition
                onPressed: {
                    previousPosition = Qt.point(mouseX, mouseY)
                }

                onMouseXChanged: {
                    if (pressedButtons == Qt.LeftButton) {
                        console.log("mouseX: " + mouseX);
                        console.log("mouseX: " + previousPosition.x);

                        var x = control.element.pos.x + mouseX - previousPosition.x;
                        var y = control.element.pos.y + mouseY - previousPosition.y;
                        var w = control.element.width - mouseX + previousPosition.x;
                        var h = control.element.height - mouseY + previousPosition.y;
                        setGeometry(x, y, w, h)
                    }
                }
            }
        }

        Rectangle {
            width: rulersSize
            height: rulersSize
            color: "yellow"
            anchors.top: parent.top
            anchors.right: parent.right

            MouseArea {
                id: mouseAreaTopRight
                anchors.fill: parent
                hoverEnabled: true
                drag.target: parent

                property variant previousPosition
                onPressed: {
                    previousPosition = Qt.point(mouseX, mouseY)
                }

                onMouseXChanged: {
                    if (pressedButtons == Qt.LeftButton) {

                        var x = control.element.pos.x;
                        var y = control.element.pos.y + mouseY - previousPosition.y;
                        var w = control.element.width + mouseX - previousPosition.x;
                        var h = control.element.height - mouseY + previousPosition.y;
                        setGeometry(x, y, w, h)
                    }
                }
            }
        }

        Rectangle {
            width: rulersSize
            height: rulersSize
            color: "yellow"
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            MouseArea {
                id: mouseAreaBottomRight
                anchors.fill: parent
                hoverEnabled: true
                drag.target: parent

                property variant previousPosition
                onPressed: {
                    previousPosition = Qt.point(mouseX, mouseY)
                }

                onMouseXChanged: {
                    if (pressedButtons == Qt.LeftButton) {

                        var x = control.element.pos.x;
                        var y = control.element.pos.y;
                        var w = control.element.width + mouseX - previousPosition.x;
                        var h = control.element.height + mouseY - previousPosition.y;
                        setGeometry(x, y, w, h)
                    }
                }
            }
        }

        Rectangle {
            width: rulersSize
            height: rulersSize
            color: "yellow"
            anchors.bottom: parent.bottom
            anchors.left: parent.left

            MouseArea {
                id: mouseAreaBottomLeft
                anchors.fill: parent
                hoverEnabled: true
                drag.target: parent

                property variant previousPosition
                onPressed: {
                    previousPosition = Qt.point(mouseX, mouseY)
                }

                onMouseXChanged: {
                    if (pressedButtons == Qt.LeftButton) {

                        var x = control.element.pos.x + mouseX - previousPosition.x;
                        var y = control.element.pos.y;
                        var w = control.element.width - mouseX + previousPosition.x;
                        var h = control.element.height + mouseY - previousPosition.y;
                        setGeometry(x, y, w, h)
                    }
                }
            }
        }
    }


    function move(dx, dy) {
        var cmd = KDSME.CommandFactory.modifyElement(control.element);
        cmd.moveBy(dx, dy);
        commandController.push(cmd);
    }

    function resize(dw, dh) {
        var cmd = KDSME.CommandFactory.modifyElement(control.element);
        cmd.resize(dw, dh);
        commandController.push(cmd);
    }

    function setGeometry(x, y, w, h) {
        var cmd = KDSME.CommandFactory.modifyElement(control.element);
        cmd.setGeometry(Qt.rect(x, y, w, h));
        commandController.push(cmd);
    }
}
