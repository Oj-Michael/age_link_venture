import 'package:agelink_venture/utils/app_theme.dart';
import 'package:agelink_venture/utils/constants.dart';
import 'package:flutter/material.dart';

class AppScrollColumn {
  const AppScrollColumn({required this.label, required this.minWidth});

  final Widget label;
  final double minWidth;
}

class AppScrollRow {
  const AppScrollRow({
    required this.cells,
    this.onTap,
  });

  final List<Widget> cells;
  final VoidCallback? onTap;
}

class AppScrollableDataTable extends StatelessWidget {
  const AppScrollableDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.headingRowHeight = 48,
    this.dataRowMinHeight = 48,
  });

  final List<AppScrollColumn> columns;
  final List<AppScrollRow> rows;
  final double headingRowHeight;
  final double dataRowMinHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalMin =
            columns.fold<double>(0, (sum, c) => sum + c.minWidth);
        final tableWidth = constraints.maxWidth > totalMin
            ? constraints.maxWidth
            : totalMin;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: headingRowHeight,
                  decoration: BoxDecoration(
                    color: AppColors.pageBackground,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      for (final col in columns)
                        SizedBox(
                          width: tableWidth * (col.minWidth / totalMin),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: col.label,
                          ),
                        ),
                    ],
                  ),
                ),
                ...rows.map((row) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: row.onTap,
                      child: Container(
                        constraints: BoxConstraints(minHeight: dataRowMinHeight),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.border),
                          ),
                        ),
                        child: Row(
                          children: [
                            for (var i = 0; i < columns.length; i++)
                              SizedBox(
                                width:
                                    tableWidth * (columns[i].minWidth / totalMin),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: row.cells[i],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget tableHeader(String text) => Text(text, style: AppTextStyles.tableHeader);

Widget tableCell(String text, {Color? color}) => Text(
      text,
      style: AppTextStyles.tableCell.copyWith(color: color),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
