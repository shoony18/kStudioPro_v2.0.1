const functions = require('firebase-functions');
const admin = require('firebase-admin');
const firebase = require("firebase");

firebase.initializeApp({
    serviceAccount: "serviceAccountCredentials.json",
    databaseURL: "https://track-77d10.firebaseio.com"
});
admin.initializeApp();

exports.applyPush = functions.database.ref('/myApply/{uuid}/{applyID}/fcmTrigger')
.onUpdate((snapshot, context) => {

    const fcmTokenRef = firebase.database().ref("user");
//    const event = snapshot.val();
    const uuid = context.params.uuid;
//    const uuid = "Md6mcXj1s6Xkq64gCYeVTYb4Jph1";

//    const uuid = eventRef.parent.child("uuid").val();

    return fcmTokenRef.once('value').then(function(snapshot) {
        const token = snapshot.child(uuid).child("fcmToken").val();
        const tokenStatus = snapshot.child(uuid).child("fcmTokenStatus").val();
        if (tokenStatus === "1") {
            const options = {
                priority: "high",  
            };
        // 通知のJSON
            const payload = {
                notification: {
                    title: "【お知らせ】",
                    body: "新着メッセージがあります",
                    badge: "1",
                    sound:"default",
                }
            };
            console.log("fcmToken:", token);
            admin.messaging().sendToDevice(token, payload, options)
        }
        return;
    });
});