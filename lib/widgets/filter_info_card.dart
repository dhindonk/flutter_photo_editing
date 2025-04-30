import 'package:flutter/material.dart';
import 'package:flutter_edit_photo_app/constants/app_theme.dart';
import 'package:flutter_edit_photo_app/utils/theory_info.dart';

class FilterInfoCard extends StatefulWidget {
  final String filterType;

  const FilterInfoCard({
    super.key,
    required this.filterType,
  });

  @override
  State<FilterInfoCard> createState() => _FilterInfoCardState();
}

class _FilterInfoCardState extends State<FilterInfoCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final info = TheoryInfo.getInfo(widget.filterType);

    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(
                info['title'] ?? 'Info',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            if (_expanded)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  info['description'] ?? 'Tidak ada info',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
