import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/placeholder_data_service.dart';

/// Displays a selectable sensor cluster/room chip with icon and name
class SensorClusterCard extends StatelessWidget {
  final SensorCluster cluster;
  final bool isSelected;
  final VoidCallback onTap;

  const SensorClusterCard({
    super.key,
    required this.cluster,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              cluster.icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              cluster.name,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
