import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../theme.dart';

class RatingStar extends StatefulWidget {
  final int? rating;
  final int? index;
  final double? starHeight;
  final Function(int? newrate)? updateRating;
  RatingStar({
    Key? key,
    this.rating,
    this.updateRating,
    this.index,
    this.starHeight,
  }) : super(key: key);

  @override
  _RatingStarState createState() => _RatingStarState();
}

class _RatingStarState extends State<RatingStar> {
  bool isTapped = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.updateRating!(widget.index);
      },
      child: SvgPicture.asset(
        widget.rating! >= widget.index!
            ? 'assets/images/icons/newIcons/starFilled.svg'
            : 'assets/images/icons/newIcons/star.svg',
        color: zimkeyOrange.withOpacity(1.0),
        height: widget.starHeight ?? 30,
      ),
    );
  }
}
