const functions = require("firebase-functions");

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const admin = require('firebase-admin');
admin.initializeApp();



exports.realizeFollow = functions.firestore.document('followers/{followerId}/userFollowers/{followingId}').onCreate(async (snapshot, context) => {
    const followingId = context.params.followingId;
    const followerId = context.params.followerId;

    const postsSnapshot = await admin.firestore().collection("posts").doc(followerId).collection("userPosts").get();
    postsSnapshot.forEach((doc) => {
        if (doc.exists) {
            const postID = doc.id;
            const postData = doc.data();
            admin.firestore().collection("flows").doc(followingId).collection("userFlowPosts").doc(postID).set(postData);
        }
    })
});
exports.followOut = functions.firestore.document('followers/{followerId}/userFollowers/{followingId}').onDelete(async (snapshot, context) => {
    const followingId = context.params.followingId;
    const followerId = context.params.followerId;

    const postsSnapshot = await admin.firestore().collection("flows").doc(followingId).collection("userFlowPosts").where("userID", "==", followerId).get();
    postsSnapshot.forEach((doc) => {
        if (doc.exists) {
            doc.ref.delete();
        }
    })
});
exports.addedNewPost = functions.firestore.document('posts/{followingId}/userPosts/{postId}').onCreate(async (snapshot, context) => {
    const followingId = context.params.followingId;
    const postID = context.params.postId;
    const newPostData = snapshot.data();
    const sanpshotFollowers = await admin.firestore().collection("followers").doc(followingId).collection("userFollowers").get();
    sanpshotFollowers.forEach((doc) => {
        const followerId = doc.id;
        admin.firestore().collection("flows").doc(followerId).collection("userFlowPosts").doc(postID).set(newPostData);
    })
});
exports.updatedPost = functions.firestore.document('posts/{followingId}/userPosts/{postId}').onUpdate(async (change, context) => {
    const followingId = context.params.followingId;
    const postID = context.params.postId;
    const updatedPostData = change.after.data();
    const sanpshotFollowers = await admin.firestore().collection("followers").doc(followingId).collection("userFollowers").get();
    sanpshotFollowers.forEach((doc) => {
        const followerId = doc.id;
        admin.firestore().collection("flows").doc(followerId).collection("userFlowPosts").doc(postID).update(updatedPostData);
    })
});
exports.deletePost = functions.firestore.document('posts/{followingId}/userPosts/{postId}').onUpdate(async (snapshot, context) => { 
    const followingId= context.params.followingId;
    const postID=context.params.postId;
    const sanpshotFollowers= await admin.firestore().collection("followers").doc(followingId).collection("userFollowers").get();
    sanpshotFollowers.forEach((doc)=>{
        const followerId=doc.id;
        admin.firestore().collection("flows").doc(followerId).collection("userFlowPosts").doc(postID).delete();
    })
 });
/*
exports.createSnap= functions.firestore.document('try/{docId}').onCreate((snapshot, context) => { 
    // console.log("hello world");
    // console.log(context.params.docId);
    admin.firestore().collection("daily").add({
        "description":"added new document"
    });
 });
 exports.removeSnap= functions.firestore.document('try/{docId}').onDelete((snapshot, context) => { 
    admin.firestore().collection("daily").add({
        "description":"removed new document"
    });
 });

 exports.updateSnap= functions.firestore.document('try/{docId}').onUpdate((change, context) => { 
    admin.firestore().collection("daily").add({
        "description":"updated new document"
    });
 });

 exports.realizeSnap= functions.firestore.document('try/{docId}').onWrite((change, context) => { 
    admin.firestore().collection("daily").add({
        "description":"updated,removed,added has occured"
    });
 });

 */