import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final bool hasNextPage;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.hasNextPage,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MouseRegion(
          cursor: currentPage > 1
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: Opacity(
            opacity: currentPage > 1 ? 1.0 : 0.3,
            child: ElevatedButton(
              onPressed: currentPage > 1 ? onPrevious : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
              ),
              child: const Text("Prethodna"),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Stranica $currentPage",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 16),
        MouseRegion(
          cursor: hasNextPage
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: Opacity(
            opacity: hasNextPage ? 1.0 : 0.3,
            child: ElevatedButton(
              onPressed: hasNextPage ? onNext : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
              ),
              child: const Text("Sljedeća"),
            ),
          ),
        ),
      ],
    );
  }
}
