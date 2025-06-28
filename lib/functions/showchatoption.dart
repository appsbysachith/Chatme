import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showChatoption(BuildContext context, String receiverUserId) {
  showDialog(
    context: context,
    builder:
        (context) => SimpleDialog(
          title: Text('Start chat'),
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('Want to start a chat?'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        child: Text('Yes'),
                        onPressed: () {
                          context.push('/chatscreen', extra: receiverUserId);
                        },
                      ),
                      ElevatedButton(
                        child: Text('No'),
                        onPressed: () {
                          context.pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
  );
}
