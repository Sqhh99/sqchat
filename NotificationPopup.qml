import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: notificationPopup
    x: parent.width - width - 20
    y: 20
    width: 300
    height: 80
    
    property string title: ""
    property string message: ""
    property int duration: 3000
    
    // 入场动画
    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                property: "x"
                from: parent.width
                to: parent.width - notificationPopup.width - 20
                duration: 300
                easing.type: Easing.OutBack
            }
        }
    }
    
    // 退场动画
    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 200
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                property: "x"
                from: notificationPopup.x
                to: parent.width
                duration: 200
                easing.type: Easing.InQuad
            }
        }
    }
    
    background: Rectangle {
        color: "#ffffff"
        border.color: "#e9ecef"
        border.width: 1
        radius: 8
        
        // 阴影效果
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            color: "transparent"
            border.color: "#20000000"
            border.width: 1
            radius: 10
            z: -1
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        
        Text {
            text: notificationPopup.title
            font.bold: true
            font.pixelSize: 14
            color: "#212529"
        }
        
        Text {
            text: notificationPopup.message
            font.pixelSize: 12
            color: "#6c757d"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }
    
    // 自动关闭
    Timer {
        running: notificationPopup.opened
        interval: notificationPopup.duration
        onTriggered: notificationPopup.close()
    }
    
    // 点击关闭
    MouseArea {
        anchors.fill: parent
        onClicked: notificationPopup.close()
    }
    
    function show() {
        open()
    }
}
