import 'package:mailer/mailer.dart';
     import 'package:mailer/smtp_server.dart';

     void main() async {
       final smtpServer = SmtpServer(
         'smtp.gmail.com',
         port: 587,
         username: 'osandihirimuthugodage23.se@gmail.com',
         password: 'jkei qsci dhlm tkoa',
         ssl: false,
         allowInsecure: true,
       );
       final message = Message()
         ..from = Address('osandihirimuthugodage23.se@gmail.com', 'Test')
         ..recipients.add('hirimuthugodageosandi@gmail.com')
         ..subject = 'Test Email'
         ..text = 'This is a test email from Flutter.';
       try {
         final sendReport = await send(message, smtpServer);
         print('Email sent: $sendReport');
       } catch (e) {
         print('Error: $e');
       }
     }