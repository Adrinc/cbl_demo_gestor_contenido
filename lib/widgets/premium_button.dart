import 'package:flutter/material.dart';
import 'package:energy_media/theme/theme.dart';

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final double borderRadius;

  const PremiumButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppTheme.of(context).primaryColor;
    final fgColor = widget.foregroundColor ?? const Color(0xFF0B0B0D);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          height: widget.height ?? 48,
          decoration: BoxDecoration(
            gradient: widget.isOutlined
                ? null
                : (_isHovered
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          bgColor.withOpacity(0.9),
                          bgColor,
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          bgColor,
                          bgColor.withOpacity(0.8),
                        ],
                      )),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.isOutlined
                ? Border.all(
                    color: bgColor,
                    width: 2,
                  )
                : null,
            boxShadow: widget.isOutlined
                ? null
                : [
                    BoxShadow(
                      color: bgColor.withOpacity(_isHovered ? 0.5 : 0.3),
                      blurRadius: _isHovered ? 20 : 12,
                      offset: Offset(0, _isHovered ? 8 : 4),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            widget.isOutlined ? bgColor : fgColor,
                          ),
                        ),
                      )
                    else ...[
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: widget.isOutlined ? bgColor : fgColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: widget.isOutlined ? bgColor : fgColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
