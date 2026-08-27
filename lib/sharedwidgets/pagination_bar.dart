import 'package:agelink_venture/utils/app_theme.dart';
import 'package:agelink_venture/utils/constants.dart';
import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.onPageChanged,
  });

  final int page;
  final int pageSize;
  final int totalItems;
  final ValueChanged<int> onPageChanged;

  int get totalPages => totalItems == 0 ? 1 : (totalItems / pageSize).ceil();

  int get start => totalItems == 0 ? 0 : page * pageSize + 1;

  int get end => ((page + 1) * pageSize).clamp(0, totalItems);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            totalItems == 0
                ? 'No results'
                : 'Showing $start–$end of $totalItems',
            style: AppTextStyles.kpiTrendMuted.copyWith(fontSize: 13),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Previous page',
            onPressed: page > 0 ? () => onPageChanged(page - 1) : null,
            icon: const Icon(Icons.chevron_left),
            iconSize: 22,
          ),
          for (var i = 0; i < totalPages && i < 7; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Material(
                color: i == page
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  onTap: () => onPageChanged(i),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: i == page ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (totalPages > 7)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text('…', style: AppTextStyles.kpiTrendMuted),
            ),
          IconButton(
            tooltip: 'Next page',
            onPressed: page < totalPages - 1
                ? () => onPageChanged(page + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            iconSize: 22,
          ),
        ],
      ),
    );
  }
}
