import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatchRow extends StatefulWidget {
  final String matchId;
  final String time;
  final String home;
  final String away;
  final String category;
  final String fieldName;
  final String status;

  const MatchRow({
    super.key,
    required this.matchId,
    required this.time,
    required this.home,
    required this.away,
    required this.category,
    required this.fieldName,
    required this.status,
  });

  @override
  State<MatchRow> createState() => _MatchRowState();
}

class _MatchRowState extends State<MatchRow> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadFavorite();
  }

  Future<void> loadFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? [];

    setState(() {
      isFavorite = favs.contains(widget.matchId);
    });
  }

  Future<void> toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();

    final favs =
        prefs.getStringList('favorites') ?? [];

    if (favs.contains(widget.matchId)) {
      favs.remove(widget.matchId);
    } else {
      favs.add(widget.matchId);
    }

    await prefs.setStringList(
      'favorites',
      favs,
    );

    setState(() {
      isFavorite = favs.contains(widget.matchId);
    });
  }

  Color statusColor() {
    switch (widget.status) {
      case 'suspendido':
        return Colors.red;

      case 'reprogramado':
        return Colors.orange;

      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 70,
              decoration: BoxDecoration(
                color: statusColor(),
                borderRadius:
                BorderRadius.circular(10),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.time,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${widget.home} vs ${widget.away}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          widget.category,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.fieldName,
                    style: TextStyle(
                      color:
                      Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              icon: Icon(
                isFavorite
                    ? Icons.star
                    : Icons.star_border,
                color: isFavorite
                    ? Colors.amber
                    : Colors.grey,
              ),
              onPressed: toggleFavorite,
            ),
          ],
        ),
      ),
    );
  }
}