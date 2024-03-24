import 'package:flutter/material.dart';

class SupportUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A0DAD),
        foregroundColor: Colors.white,
        title: Text('Support Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Support My App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Your support means a lot to us! Here are some ways you can support our app:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              '1. Rate and Review:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'If you enjoy using our app, please consider leaving a positive review on the app store/play store.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              '2. Spread the Word:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Tell your friends and family about our app. Word of mouth is a powerful way to help us grow.',
              style: TextStyle(fontSize: 16),
            ),
            // Add more support options as needed
          ],
        ),
      ),
    );
  }
}
