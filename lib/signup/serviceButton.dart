import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:recase/recase.dart';

import '../models/serviceModel.dart';
import '../theme.dart';

class ServiceButton extends StatefulWidget {
  final AllServices? subServ;
  final Function(bool selection)? updateServiceSelection;
  ServiceButton({
    Key? key,
    this.subServ,
    this.updateServiceSelection,
  }) : super(key: key);

  @override
  _ServiceButtonState createState() => _ServiceButtonState();
}

class _ServiceButtonState extends State<ServiceButton> {
  bool isselected = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isselected = !isselected;
        });
        widget.updateServiceSelection!(isselected);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/images/icons/newIcons/tick-circle.svg',
              color:
                  isselected ? zimkeyOrange : zimkeyDarkGrey.withOpacity(0.3),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              ReCase('${widget.subServ!.name}').titleCase,
              style: TextStyle(
                fontSize: 15,
                color: zimkeyDarkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
