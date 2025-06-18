import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: contactItem
    height: 72
    color: isSelected ? "#e3f2fd" : (mouseArea.containsMouse ? "#f5f5f5" : "transparent")
    radius: 8
    border.color: isSelected ? "#2196f3" : "transparent"
    border.width: 1
    
    property var contactData
    property bool isSelected: false
    
    signal clicked()
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: contactItem.clicked()
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        
        // 头像和在线状态
        Item {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            
            Rectangle {
                width: 48
                height: 48
                radius: 24
                color: "#e9ecef"
                border.color: contactData.isOnline ? "#22c55e" : "#dee2e6"
                border.width: 2
                
                Text {
                    anchors.centerIn: parent
                    text: contactData.avatar
                    font.pixelSize: 20
                }
            }
            
            // 在线状态指示器
            Rectangle {
                width: 12
                height: 12
                radius: 6
                color: contactData.isOnline ? "#22c55e" : "#6c757d"
                border.color: "white"
                border.width: 2
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.rightMargin: 2
                anchors.bottomMargin: 2
            }
        }
        
        // 联系人信息
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4
            
            // 名字和时间
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: contactData.name
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: "#212529"
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                
                Text {
                    text: contactData.timestamp
                    font.pixelSize: 12
                    color: "#6c757d"
                }
            }
            
            // 最后消息和未读数
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: contactData.lastMessage
                    font.pixelSize: 14
                    color: "#6c757d"
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    wrapMode: Text.NoWrap
                }
                
                // 未读消息数
                Rectangle {
                    visible: contactData.unreadCount > 0
                    width: 20
                    height: 20
                    radius: 10
                    color: "#dc3545"
                    
                    Text {
                        anchors.centerIn: parent
                        text: contactData.unreadCount
                        color: "white"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }
                }
            }
        }
    }
}
