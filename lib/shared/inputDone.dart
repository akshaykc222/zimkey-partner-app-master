import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';

import '../theme.dart';

class InputDoneView extends StatefulWidget {
  final String? buttonText;
  final FocusNode? nextNode;

  const InputDoneView({
    Key? key,
    this.buttonText,
    this.nextNode,
  }) : super(key: key);

  @override
  State<InputDoneView> createState() => _InputDoneViewState();
}

class _InputDoneViewState extends State<InputDoneView> {
  @override
  Widget build(BuildContext context) {
    if (Device.get().isIos)
      return Container(
        width: double.infinity,
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            width: 140,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: CupertinoButton(
              borderRadius: BorderRadius.circular(5),
              color: zimkeyDarkGrey.withOpacity(0.2),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              onPressed: () {
                if (widget.nextNode == null)
                  FocusScope.of(context).requestFocus(new FocusNode());
                else
                  FocusScope.of(context).requestFocus(widget.nextNode);
              },
              child: Text(
                widget.buttonText ?? "Done",
                style: TextStyle(
                  fontSize: 17,
                  color: zimkeyBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    else
      return Container(
        height: 0,
        width: 0,
      );
  }
}

class HelperWidgets {
  static Widget buildText({required String text,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
    Color color =zimkeyBlack,
    TextAlign? textAlign,
    TextOverflow? overflow = TextOverflow.ellipsis,
    int? maxLines}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}