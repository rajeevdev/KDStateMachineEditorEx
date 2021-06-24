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
    property bool resizeActive: false
    property bool resizing: false

    signal clicked
    signal doubleClicked

    property int rulersSize: 10
    Rectangle {
        id: rect

        anchors.fill: parent

        border {
            color: resizeActive ? "steelblue" : Theme.currentTheme.highlightBackgroundColor
            width: 2
        }
        color: "transparent"
//        opacity: resizing ? 0.5 : 1

        visible: control ?
                     control.element.flags & KDSME.Element.ElementIsSelectable && control.element.selected :
                     false


        //        MouseArea {
        //            id: mouseArea2
        //            anchors.fill: parent
        //            hoverEnabled: true
        //        }

        Rectangle {
            width: rulersSize
            height: rulersSize
            color: resizeActive ? "steelblue" : Theme.currentTheme.highlightBackgroundColor
            anchors.right: parent.right
            anchors.bottom: parent.bottom


            //            MouseArea {
            //                anchors.fill: parent
            //                drag.target: parent
            //                property var previousPosition
            //                property var previousSize

            //                function resize(dw, dh) {
            //                    var cmd = KDSME.CommandFactory.modifyElement(control.element);
            //                    cmd.resize(dw, dh);
            //                    commandController.push(cmd);
            //                }

            //                onPressed: {
            //                    previousPosition = Qt.point(mouseX, mouseY)
            //                    previousSize = Qt.size(rect.width, rect.height)
            //                }

            //                onPositionChanged: {
            //                   if (pressedButtons == Qt.LeftButton) {
            //                       console.log("============================")
            //                       console.log(previousSize.width)
            //                       console.log(mouseX)
            //                       console.log(previousPosition.x)
            //                       var dw = previousSize.width + mouseX
            //                       console.log(dw)
            //                       var dh = previousSize.height + mouseY
            //                       resize(dw, dh)
            //                   }
            //                }
            //            }
        }
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: true

        //        width: parent.width - 10
        //        height: parent.height - 10
        //        anchors.centerIn: parent
        anchors.fill: parent

        drag.target: control.element.flags & KDSME.Element.ElementIsDragEnabled ?
                         parent :
                         null

        property variant previousPosition
        property var previousSize

        onClicked: {
            scene.currentItem = control.element;
            root.clicked();
        }
        onDoubleClicked: {
            root.doubleClicked();
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

        onPressed: {
            previousPosition = Qt.point(mouseX, mouseY)
            previousSize = Qt.size(root.width, root.height)
            if (resizeActive)
                resizing = true
        }

        onReleased: {
            resizing = false
        }

        onExited: {
            if (!pressed) {
                resizeActive = false
            }
        }

        onPositionChanged: {
            if (mouseX < root.width && mouseX >= root.width - rulersSize
                    && mouseY < root.height && mouseY >= root.height - rulersSize)
            {
                resizeActive = true
            }
            else
            {
                if (!pressed) {
                    resizeActive = false
                }
            }

            if (pressedButtons == Qt.LeftButton) {

                if (resizing) {
                    var dx = mouseX - previousPosition.x
                    var dy = mouseY - previousPosition.y
                    var dw = previousSize.width + dx
                   var dh = previousSize.height + dy
                   resize(dw, dh)
                } else {
                    var dx = mouseX - previousPosition.x
                    var dy = mouseY - previousPosition.y
                    move(dx, dy)
                }

            }
        }
    }
}
