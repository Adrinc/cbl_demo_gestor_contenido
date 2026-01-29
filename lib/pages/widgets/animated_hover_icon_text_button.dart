import 'package:energy_media/theme/theme.dart';
import 'package:flutter/material.dart';

class AnimatedHoverIconTextButton extends StatefulWidget {
  const AnimatedHoverIconTextButton({
    Key? key,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
    required this.icon,
    required this.text,
    required this.tooltip,
    this.size = 45,
    this.enable = true,
  }) : super(key: key);

  final Color primaryColor;
  final Color secondaryColor;
  final void Function() onTap;
  final IconData icon;
  final String text;
  final String? tooltip;
  final double? size;
  final bool? enable;

  @override
  State<AnimatedHoverIconTextButton> createState() =>
      _AnimatedHoverButtonState();
}

class _AnimatedHoverButtonState extends State<AnimatedHoverIconTextButton> {
  late Color primaryColor;
  late Color secondaryColor;

  void setColors(bool isPrimary) {
    if (isPrimary) {
      if (widget.enable == true) {
        primaryColor = widget.primaryColor;
        secondaryColor = widget.secondaryColor;
      } else {
        primaryColor = AppTheme.of(context).hintText;
        secondaryColor = AppTheme.of(context).primaryBackground;
      }
    } else {
      if (widget.enable == true) {
        primaryColor = widget.secondaryColor;
        secondaryColor = widget.primaryColor;
      } else {
        primaryColor = AppTheme.of(context).primaryBackground;
        secondaryColor = AppTheme.of(context).hintText;
      }
    }
  }

  @override
  void initState() {
    primaryColor = widget.primaryColor;
    secondaryColor = widget.secondaryColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTap: widget.enable == true ? widget.onTap : null,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => setColors(false)),
          onExit: (_) => setState(() => setColors(true)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            //width: (MediaQuery.of(context).size.width * 48 / 1920),
            //height: (MediaQuery.of(context).size.width * 48 / 1920),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              border: Border.all(
                color: primaryColor,
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: primaryColor,
                    size: (MediaQuery.of(context).size.width * 25 / 1920),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.text,
                    style: AppTheme.of(context).bodyText3.override(
                          fontFamily: AppTheme.of(context).bodyText3Family,
                          color: primaryColor,
                        ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
