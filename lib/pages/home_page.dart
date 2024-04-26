import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_drawer.dart';
import 'package:flutter_application_1/components/user_tile.dart';
import 'package:flutter_application_1/pages/chat_page.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
import 'package:flutter_application_1/services/chat/chat_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatService _chatService=ChatService();
  final AuthService _authService=AuthService();

  void logout(){
    //auth service
    final auth=AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  //list users except current logged in users
  Widget _buildUserList(){
    return StreamBuilder(
      stream: _chatService.getUsersStream(), 
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
          children: snapshot.data!.map<Widget>((userData)=>_buildUserListItem(userData,context)).toList(),
        );
      },
    );
  }

  //individual list tile for user
  Widget _buildUserListItem(Map<String,dynamic>userData,BuildContext context){
    //display all users except current user
    if(userData["email"]!=_authService.getCurrentUser()!.email){
      return UserTile(
        text: userData["email"], 
        onTap: (){
          //while tapping,goto chatpage
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context)=>ChatPage(
                recieverEmail: userData["email"],
                recieverID: userData["uid"],
              ),
            )
          );
        },
      );
    }
    else{
      return Container();
    }
  }
}