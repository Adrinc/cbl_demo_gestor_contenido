import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ButtonOptions {
  ButtonOptions({
    this.textStyle,
    this.elevation,
    this.height = 50,
    this.width,
    this.padding,
    required this.color,
    this.disabledColor = const Color(0xFF57636C),
    this.disabledTextColor = const Color(0xFFc1c7cc),
    this.splashColor,
    this.iconSize,
    this.iconColor,
    this.iconPadding,
    this.borderRadius,
    this.borderSide,
    this.disabled = false,
  });

  final TextStyle? textStyle;
  final double? elevation;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Color color;
  final Color disabledColor;
  final Color disabledTextColor;
  final Color? splashColor;
  final double? iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry? iconPadding;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;
  final bool disabled;
}

class CustomButton extends StatefulWidget {
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconData,
    required this.options,
    this.showLoadingIndicator = true,
  }) : super(key: key);

  final String text;
  final Widget? icon;
  final IconData? iconData;
  final Function() onPressed;
  final ButtonOptions options;
  final bool showLoadingIndicator;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Widget textWidget = loading
        ? Center(
            child: SizedBox(
              width: 23,
              height: 23,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.options.textStyle?.color ?? Colors.white,
                ),
              ),
            ),
          )
        : AutoSizeText(
            widget.text,
            style: widget.options.textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );

    final onPressed =
        widget.options.disabled || (widget.showLoadingIndicator && loading)
            ? null
            : () async {
                if (!widget.showLoadingIndicator) {
                  widget.onPressed();
                  return;
                }
                setState(() => loading = true);
                try {
                  await widget.onPressed();
                } finally {
                  if (mounted) {
                    setState(() => loading = false);
                  }
                }
              };

    ButtonStyle style = ButtonStyle(
      shape: MaterialStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius:
              widget.options.borderRadius ?? BorderRadius.circular(8.0),
          side: widget.options.borderSide ?? BorderSide.none,
        ),
      ),
      foregroundColor: MaterialStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(MaterialState.disabled) ||
              widget.options.disabled) {
            return widget.options.disabledTextColor;
          }
          return widget.options.textStyle?.color;
        },
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(MaterialState.disabled) ||
              widget.options.disabled) {
            return widget.options.disabledColor;
          }
          return widget.options.color;
        },
      ),
      overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (widget.options.disabled) {
          return null;
        }
        if (states.contains(MaterialState.pressed)) {
          return widget.options.splashColor;
        }
        return null;
      }),
      padding: MaterialStateProperty.all(widget.options.padding ??
          const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0)),
      elevation:
          MaterialStateProperty.all<double>(widget.options.elevation ?? 2.0),
      mouseCursor: MaterialStateProperty.resolveWith<MouseCursor?>(
        (Set<MaterialState> states) {
          if (widget.options.disabled) {
            return SystemMouseCursors.basic;
          }
          return SystemMouseCursors.click;
        },
      ),
    );

    if (widget.icon != null || widget.iconData != null) {
      return SizedBox(
        height: widget.options.height,
        width: widget.options.width,
        child: ElevatedButton.icon(
          icon: Padding(
            padding: widget.options.iconPadding ?? EdgeInsets.zero,
            child: widget.icon ??
                Icon(
                  widget.iconData,
                  size: widget.options.iconSize,
                  color: widget.options.iconColor ??
                      widget.options.textStyle?.color,
                ),
          ),
          label: textWidget,
          onPressed: onPressed,
          style: style,
        ),
      );
    }

    return SizedBox(
      height: widget.options.height,
      width: widget.options.width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: textWidget,
      ),
    );
  }
}
