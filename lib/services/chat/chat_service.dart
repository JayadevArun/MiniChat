import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/message.dart';

class ChatService{
  //get instance of firestore and auth
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  final FirebaseAuth _auth=FirebaseAuth.instance;

  //get user stream
  /*
  
  List<Map<String,dynamic>>=

  [
    {
      'email': test@gmail.com,
      'id': ..
    },
    {
      'email': jayadev@gmail.com,
      'id': ..
    },
  ]
  */

  Stream<List<Map<String,dynamic>>> getUsersStream(){
    return _firestore.collection("Users").snapshots().map((snapshot){
      return snapshot.docs.map((doc){
        final user=doc.data();

        return user;
      }).toList();
    });
  }

  //send message
  Future<void> sendMessage(String recieverID,message)async{
    //get current user info
    final String currentUserID=_auth.currentUser!.uid;
    final String currentUserEmail=_auth.currentUser!.email!;
    final Timestamp timestamp=Timestamp.now();

    //create a new message
    Message newMessage=Message(
      senderID: currentUserID, 
      senderEmail: currentUserEmail, 
      recieverID: recieverID, 
      message: message, 
      timestamp: timestamp,
    );

    //construct chatroom id for 2 users
    List<String> ids=[currentUserID,recieverID];
    ids.sort(); //sort ids(to ensure chatroom id is same for 2 user)
    String chatRoomID=ids.join('_');

    //add new message to database
    await _firestore
      .collection("chat_rooms")
      .doc(chatRoomID)
      .collection("messages")
      .add(newMessage.toMap());

  }

  //get message
  Stream<QuerySnapshot> getMessages(String userID,otherUserID){
    //construct chatroom id for 2 users
    List<String> ids=[userID,otherUserID];
    ids.sort();
    String chatRoomID=ids.join('_');

    return _firestore
      .collection("chat_rooms")
      .doc(chatRoomID)
      .collection("messages")
      .orderBy("timestamp",descending: false)
      .snapshots();
  }

}