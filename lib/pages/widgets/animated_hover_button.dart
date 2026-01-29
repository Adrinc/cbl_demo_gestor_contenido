import 'package:flutter/material.dart';

class AnimatedHoverButton extends StatefulWidget {
  const AnimatedHoverButton({
    Key? key,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
    required this.icon,
    required this.tooltip,
    this.radius = 50,
    this.size = 50,
    this.enable = true,
  }) : super(key: key);

  final Color primaryColor;
  final Color secondaryColor;
  final void Function() onTap;
  final IconData icon;
  final String tooltip;
  final double radius;
  final double size;
  final bool? enable;

  @override
  State<AnimatedHoverButton> createState() => _AnimatedHoverButtonState();
}

class _AnimatedHoverButtonState extends State<AnimatedHoverButton> {
  bool isHovered = false;

  void setHovered(bool hovered) {
    setState(() {
      isHovered = hovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor;
    final Color secondaryColor;

    if (!isHovered) {
      if (widget.enable == true) {
        primaryColor = widget.primaryColor;
        secondaryColor = widget.secondaryColor;
      } else {
        primaryColor = Theme.of(context).hintColor;
        secondaryColor = Theme.of(context).scaffoldBackgroundColor;
      }
    } else {
      if (widget.enable == true) {
        primaryColor = widget.secondaryColor;
        secondaryColor = widget.primaryColor;
      } else {
        primaryColor = Theme.of(context).scaffoldBackgroundColor;
        secondaryColor = Theme.of(context).hintColor;
      }
    }

    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTap: widget.enable == true ? widget.onTap : null,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setHovered(true),
          onExit: (_) => setHovered(false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(widget.radius),
              border: Border.all(
                color: primaryColor,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                widget.icon,
                color: primaryColor,
                size: widget.size / 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
