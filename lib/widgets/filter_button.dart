import 'package:flutter/material.dart';
import 'package:flutter_edit_photo_app/constants/app_theme.dart';

class FilterButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool disabled;

  const FilterButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  bool _isLoading = false;

  void _startLoading() {
    if (mounted && !_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }
  }

  void _stopLoading() {
    if (mounted && _isLoading) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePress() async {
    if (widget.onPressed != null && !widget.disabled) {
      _startLoading();

      try {
        // Panggil onPressed dalam microtask agar UI dapat diupdate terlebih dahulu
        Future.microtask(() => widget.onPressed!());
      } finally {
        // Delay minimal untuk memastikan UI loading terlihat
        await Future.delayed(const Duration(milliseconds: 200));
        _stopLoading();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: (widget.disabled || _isLoading) ? null : _handlePress,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(widget.icon, size: 24),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
