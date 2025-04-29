import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:awesome_card/awesome_card.dart';

class CreditCardForm extends StatefulWidget {
  const CreditCardForm({super.key});

  @override
  State<CreditCardForm> createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvv = '';
  bool showBack = false;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberCtrl = TextEditingController();
  final TextEditingController _cardHolderCtrl = TextEditingController();
  final TextEditingController _expiryFieldCtrl = TextEditingController();
  final TextEditingController _cvvCtrl = TextEditingController();
  late FocusNode _cvvFocusNode;

  @override
  void initState() {
    super.initState();
    _cvvFocusNode = FocusNode();
    _cvvFocusNode.addListener(() {
      setState(() {
        showBack = _cvvFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _cvvFocusNode.dispose();
    _cardNumberCtrl.dispose();
    _cardHolderCtrl.dispose();
    _expiryFieldCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  // Detect card type (Visa, Mastercard, etc.)
  String _getCardType(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(' ', '');
    if (cleanNumber.startsWith(RegExp(r'^4'))) return 'Visa';
    if (cleanNumber.startsWith(RegExp(r'^5[1-5]'))) return 'Mastercard';
    return 'Card';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, semanticLabel: 'Back'),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add New Card",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated credit card
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: CreditCard(
                  cardNumber: cardNumber,
                  cardExpiry: expiryDate,
                  cardHolderName: cardHolderName,
                  cvv: cvv,
                  bankName: _getCardType(cardNumber),
                  showBackSide: showBack,
                  frontBackground: CardBackgrounds.custom(
                      const Color.fromRGBO(255, 214, 75, 1).value),
                  backBackground: CardBackgrounds.white,
                  showShadow: true,
                  textExpDate: 'Exp. Date',
                  textName: 'Card Holder',
                  textExpiry: 'MM/YY',
                ),
              ),
              const SizedBox(height: 40),
              // Card Number
              TextFormField(
                controller: _cardNumberCtrl,
                keyboardType: TextInputType.number,
                maxLength: 19, // 16 digits + 3 spaces
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  counterText: '',
                ),
                validator: (value) {
                  final cleanNumber = value?.replaceAll(' ', '') ?? '';
                  if (cleanNumber.length != 16) {
                    return 'Enter a valid 16-digit card number';
                  }
                  return null;
                },
                onChanged: (value) {
                  final cleanNumber = value.replaceAll(' ', '');
                  var newStr = '';
                  const step = 4;
                  for (var i = 0; i < cleanNumber.length; i += step) {
                    newStr += cleanNumber.substring(
                        i, math.min(i + step, cleanNumber.length));
                    if (i + step < cleanNumber.length) newStr += ' ';
                  }
                  setState(() {
                    cardNumber = newStr;
                    _cardNumberCtrl.value = TextEditingValue(
                      text: newStr,
                      selection:
                          TextSelection.collapsed(offset: newStr.length),
                    );
                  });
                },
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 20),
              // Card Holder Name
              TextFormField(
                controller: _cardHolderCtrl,
                decoration: InputDecoration(
                  labelText: 'Name on Card',
                  hintText: 'John Doe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter card holder name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    cardHolderName = value.trim();
                  });
                },
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 20),
              // Expiry Date
              TextFormField(
                controller: _expiryFieldCtrl,
                keyboardType: TextInputType.number,
                maxLength: 5,
                decoration: InputDecoration(
                  labelText: 'Expiration Date',
                  hintText: 'MM/YY',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || !RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value)) {
                    return 'Enter valid MM/YY';
                  }
                  return null;
                },
                onChanged: (value) {
                  var newValue = value.trim();
                  final isBackspace = expiryDate.length > newValue.length;
                  if (newValue.length == 2 && !isBackspace && !newValue.contains('/')) {
                    newValue += '/';
                  }
                  if (newValue.length <= 5) {
                    setState(() {
                      expiryDate = newValue;
                      _expiryFieldCtrl.value = TextEditingValue(
                        text: newValue,
                        selection:
                            TextSelection.collapsed(offset: newValue.length),
                      );
                    });
                  }
                },
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 20),
              // CVV
              TextFormField(
                controller: _cvvCtrl,
                keyboardType: TextInputType.number,
                maxLength: 3,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.length != 3) {
                    return 'Enter a 3-digit CVV';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    cvv = value;
                  });
                },
                focusNode: _cvvFocusNode,
                textInputAction: TextInputAction.done,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 40),
              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isSaving = true;
                            });
                            // Simulate async save (e.g., API call)
                            await Future.delayed(const Duration(seconds: 1));
                            Navigator.pop(context, {
                              'cardNumber': cardNumber,
                              'cardHolderName': cardHolderName,
                              'expiryDate': expiryDate,
                              'cvv': cvv,
                            });
                            setState(() {
                              _isSaving = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(256, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 3,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          "SAVE",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}