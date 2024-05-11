import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  String _feedback = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback Form'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Enter your feedback',
                ),
                onSaved: (value) {
                  _feedback = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20), // Added for better spacing
              ElevatedButton(
                onPressed: _sendFeedback,
                child: Text('Send Feedback'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendFeedback() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _sendEmail();
    }
  }

  void _sendEmail() async {
    final Email email = Email(
      body: _feedback,
      subject: 'Feedback from MyApp',
      recipients: ['kidtales44@gmail.com'],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Feedback email sent successfully!'),
      ));
      print('Email send attempt finished.'); // Changed to confirm email send attempt without expecting a result
    } catch (error) {
      print('Error sending email: $error'); // This will help in identifying what went wrong
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send feedback email: $error'), // Show error in UI
      ));
    }
  }
}
