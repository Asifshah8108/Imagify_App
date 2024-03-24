import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A0DAD),
        foregroundColor: Colors.white,
        title: Text('About Imagify App'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Imagify',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 200,),
                  Image.asset('assets/icon/icon.png',height: 70,width: 70,)
                ],
              ),
              SizedBox(height: 5),
              Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 24,),
              Text(
                'Developed By:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Mohammed Asif Shah',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 24),
              Text(
                'About Company:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Welcome to Imagify, where imagination meets reality! We are an innovative app that harnesses the power of artificial intelligence to generate stunning images based on user prompts. With just a few clicks, you can bring your wildest visual ideas to life. Say goodbye to stock photos and hello to limitless creativity!',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                'Mission and Vision:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Our mission is to empower individuals and businesses to express their unique ideas through visually captivating images. We believe that everyone deserves access to top-notch graphics that inspire, engage, and leave a lasting impression. Our vision is to revolutionize the way people create and share visual content, making it accessible, fun, and effortless.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                'Core Values:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1.Creativity Unleashed: We encourage and celebrate out-of-the-box thinking, pushing boundaries, and exploring new frontiers of visual expression. Let your imagination run wild with Imagify!\n2.User-Centric Approach: Our users are at the heart of everything we do. We strive to provide an exceptional experience, listening to feedback, and continuously improving our app to meet your needs.\n3.Innovation with AI: We embrace cutting-edge technology and leverage the power of artificial intelligence to deliver groundbreaking image generation capabilities. Prepare to be amazed by the possibilities!\n4.Fun and Laughter: We believe that creativity should be a joyful experience. With a touch of humor and a sprinkle of laughter, we aim to make your Imagify journey an enjoyable one.',
                style: TextStyle(fontSize: 16),
              ),
              // Add more credits or acknowledgments as needed
            ],
          ),
        ),
      ),
    );
  }
}
