import 'package:flutter/material.dart';

class CardFormPage extends StatefulWidget {
  const CardFormPage({super.key});

  @override
  State<CardFormPage> createState() => _CardFormPageState();
}

class _CardFormPageState extends State<CardFormPage> {
  final TextEditingController cardNumberCtrl = TextEditingController();
  final TextEditingController cardHolderNameCtrl = TextEditingController();
  final TextEditingController expMonthCtrl = TextEditingController();
  final TextEditingController expYearCtrl = TextEditingController();
  final TextEditingController cvcCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    cardNumberCtrl.dispose();
    cardHolderNameCtrl.dispose();
    expMonthCtrl.dispose();
    expYearCtrl.dispose();
    cvcCtrl.dispose();
    super.dispose();
  }

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'cardNumber': cardNumberCtrl.text.trim(),
        'cardHolderName': cardHolderNameCtrl.text.trim(),
        'expMonth': expMonthCtrl.text.trim(),
        'expYear': expYearCtrl.text.trim(),
        'cvc': cvcCtrl.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Card'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildInputField(
                controller: cardNumberCtrl,
                label: 'Card Number',
                hint: '1234 5678 9012 3456',
                keyboardType: TextInputType.number,
                validator: (val) => val != null && val.length == 16 ? null : 'Enter 16-digit card number',
              ),
              _buildInputField(
                controller: cardHolderNameCtrl,
                label: 'Cardholder Name',
                hint: 'John Doe',
                validator: (val) => val != null && val.isNotEmpty ? null : 'Enter cardholder name',
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: expMonthCtrl,
                      label: 'Exp Month',
                      hint: 'MM',
                      keyboardType: TextInputType.number,
                      validator: (val) => val != null && val.length == 2 ? null : 'MM',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInputField(
                      controller: expYearCtrl,
                      label: 'Exp Year',
                      hint: 'YYYY',
                      keyboardType: TextInputType.number,
                      validator: (val) => val != null && val.length == 4 ? null : 'YYYY',
                    ),
                  ),
                ],
              ),
              _buildInputField(
                controller: cvcCtrl,
                label: 'CVC',
                hint: '123',
                keyboardType: TextInputType.number,
                validator: (val) => val != null && val.length == 3 ? null : 'Enter valid CVC',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(255, 214, 75, 1),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'SAVE CARD',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: validator,
      ),
    );
  }
}
