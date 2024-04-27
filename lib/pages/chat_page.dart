import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/chat_bubble.dart';
import 'package:flutter_application_1/components/my_textfield.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
import 'package:flutter_application_1/services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String recieverEmail;
  final String recieverID;

  ChatPage({
    super.key,
    required this.recieverEmail,
    required this.recieverID,
    });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
    //text controller
    final TextEditingController _messageController=TextEditingController();

    //chat and auth services
    final ChatService _chatService=ChatService();
    final AuthService _authService=AuthService();

    //for textfield focus
    FocusNode myFocusNode=FocusNode();

    @override
    void initState() {
      super.initState();

      //add listener to focus node
      myFocusNode.addListener((){
        if(myFocusNode.hasFocus){
          //cause a delay
          //remaining space is calculated
          //then scroll down
          Future.delayed(
            const Duration(milliseconds: 500),
            ()=>scrollDown(),
          );
        }
      });

      //wait for listview to built,then scroll to bottom
      Future.delayed(
        const Duration(milliseconds: 500),
        ()=>scrollDown(),
      );

    }

    @override
    void dispose() {
      myFocusNode.dispose();
      _messageController.dispose();
      super.dispose();
    }

    //scroll controller
    final ScrollController _scrollController=ScrollController();
    void scrollDown(){
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent, 
        duration: const Duration(seconds: 1), 
        curve: Curves.fastOutSlowIn,
      );
    }

    //send message
    void sendMessage() async{
      //if something is inside textfield
      if(_messageController.text.isNotEmpty){
        //send the message
        await _chatService.sendMessage(widget.recieverID, _messageController.text);

        //clear the controller
        _messageController.clear();
      }

      scrollDown();
    
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.recieverEmail),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [
          //display all messages
          Expanded(
            child: _buildMessageList(),
          ),

          //user input
          _buildUserInput(),
        ],
      ),
    );
  }

  //build message list
  Widget _buildMessageList(){
    String senderID=_authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.recieverID, senderID), 
      builder: (context,snapshot){
        //error
        if(snapshot.hasError){
          return const Text("Error");
        }

        //loading
        if(snapshot.connectionState==ConnectionState.waiting){
          return const Text("Loading...");
        }

        //return list view
        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs.map((doc)=>_buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot doc){
    Map<String,dynamic> data=doc.data() as Map<String,dynamic>;

    //is current user
    bool isCurrentUser=data['senderID']==_authService.getCurrentUser()!.uid;

    //align messages to right if user is sender otherwise left
    var alignment=isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            isCurrentUser: isCurrentUser, 
            message: data["message"]
          ),
        ],
      ),
    );
  }

  //build user message input
  Widget _buildUserInput(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          //text field should take more space
          Expanded(
            child: MyTextfield(
              controller: _messageController,
              hintText: "Type a messgae",
              obscureText: false,
              focusNode: myFocusNode,
            ),
          ),
      
          //send button
          Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMessage, 
              icon: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
                ),
            ),
          ),
        ],
      ),
    );
  }
}