import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'package:ruoqi_platform_pc/admin_pages/shared/table_card.dart';
import 'package:ruoqi_platform_pc/admin_pages/shared/user_management_widgets.dart';

import 'geo_models.dart';
import 'geo_plate_edit_modal.dart';

/// 基础-世界地理规划 业务正文（对应 世界地理规划 原型）。
class WorldGeoBody extends StatelessWidget {
  const WorldGeoBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        const UserPageHeader(
          title: '世界地理规划',
          description: '地球板块地理划分资料。',
        ),
        const SizedBox(height: RuQiSpacing.md),
        TableCard(
          columns: const [
            (label: '代号', flex: 8),
            (label: '大洲(基本语)名称', flex: 14),
            (label: '英文简称', flex: 14),
            (label: '操作', flex: 8),
          ],
          rowCount: geoPlates.length,
          rowBuilder: (context, index) {
            final plate = geoPlates[index];
            return [
              CellText(plate.code, strong: true),
              CellText(plate.zhName),
              CellText(plate.enName, muted: true),
              TextButton(
                style: RuQiButtonStyles.tertiary(context),
                onPressed: () => showGeoPlateEditPanel(context, plate),
                child: const Text('编辑'),
              ),
            ];
          },
        ),
      ],
    );
  }
}
