import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: notificationManager
    
    function showNotification(title, message, duration) {
        var component = Qt.createComponent("NotificationPopup.qml")
        if (component.status === Component.Ready) {
            var popup = component.createObject(notificationManager, {
                "title": title,
                "message": message,
                "duration": duration || 3000
            })
            popup.show()
        }
    }
}
