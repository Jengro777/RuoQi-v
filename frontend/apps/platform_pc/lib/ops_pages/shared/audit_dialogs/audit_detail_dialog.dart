// 审核详情（对应 查看）。
import 'package:flutter/material.dart';

class AuditDetailDialog extends StatelessWidget {
  const AuditDetailDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 700,
        height: 600,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                width: 636,
                height: 64,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 8,
                    bottom: 8,
                  ),
                  child: Text(
                    '审核详情\n',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF4C5773),
                      fontWeight: FontWeight.w700,
                      height: 1.1111,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 636,
                top: 0,
                width: 64,
                height: 64,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 8,
                            bottom: 8,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        top: 20,
                        width: 24,
                        height: 24,
                        child: Icon(
                          IconData(0xEA5B, fontFamily: 'boldIconFont'),
                          size: 24,
                          color: Color(0xFF4C5773),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 173,
                width: 100,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    '原因/说明：',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4C5773),
                      height: 1.4286,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 257,
                width: 100,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    '内部备注：',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4C5773),
                      height: 1.4286,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 213,
                width: 100,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    '图片：',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4C5773),
                      height: 1.4286,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 25,
                top: 251,
                width: 650,
                height: 0,
                child: Container(
                  width: 650,
                  height: 1,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFF949AAB), width: 1),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 297,
                width: 100,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    '图片：',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4C5773),
                      height: 1.4286,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 120,
                top: 297,
                width: 32,
                height: 32,
                child: SizedBox.shrink(),
              ),
              Positioned(
                left: 120,
                top: 213,
                width: 32,
                height: 32,
                child: SizedBox.shrink(),
              ),
              Positioned(
                left: 166,
                top: 213,
                width: 32,
                height: 32,
                child: SizedBox.shrink(),
              ),
              Positioned(
                left: 120,
                top: 141,
                width: 162,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 0,
                    top: 0,
                    bottom: 0,
                  ),
                  child: Text(
                    '10:04:32  03/29/2022',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4C5773),
                      height: 1.1667,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 141,
                width: 100,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    '审核时间：',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4C5773),
                      height: 1.4286,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 353,
                width: 700,
                height: 0,
                child: Container(
                  width: 700,
                  height: 2,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFEC808D), width: 2),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 120,
                top: 109,
                width: 162,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 0,
                    top: 0,
                    bottom: 0,
                  ),
                  child: Text(
                    'account1',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4C5773),
                      height: 1.1667,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 109,
                width: 100,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    '审核人：',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4C5773),
                      height: 1.4286,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 77,
                width: 100,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    '审核结果：',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4C5773),
                      height: 1.4286,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 120,
                top: 77,
                width: 162,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 0,
                    top: 0,
                    bottom: 0,
                  ),
                  child: Text(
                    '驳回',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEC808D),
                      height: 1.1667,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 120,
                top: 257,
                width: 426,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 0,
                    top: 0,
                    bottom: 0,
                  ),
                  child: Text(
                    '此商品不合规，实物不合规；仓库需要注意检测商品',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF949AAB),
                      height: 1.1667,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 120,
                top: 173,
                width: 426,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 0,
                    top: 0,
                    bottom: 0,
                  ),
                  child: Text(
                    '此商品不合规，实物不合规；仓库需要注意检测商品',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF949AAB),
                      height: 1.1667,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 470,
                width: 100,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    '原因/说明：',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4C5773),
                      height: 1.4286,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 554,
                width: 100,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    '内部备注：',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4C5773),
                      height: 1.4286,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 510,
                width: 100,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    '图片：',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4C5773),
                      height: 1.4286,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 25,
                top: 548,
                width: 650,
                height: 0,
                child: Container(
                  width: 650,
                  height: 1,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFF949AAB), width: 1),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 594,
                width: 100,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    '图片：',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4C5773),
                      height: 1.4286,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 120,
                top: 594,
                width: 32,
                height: 32,
                child: SizedBox.shrink(),
              ),
              Positioned(
                left: 120,
                top: 510,
                width: 32,
                height: 32,
                child: SizedBox.shrink(),
              ),
              Positioned(
                left: 166,
                top: 510,
                width: 32,
                height: 32,
                child: SizedBox.shrink(),
              ),
              Positioned(
                left: 120,
                top: 438,
                width: 162,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 0,
                    top: 0,
                    bottom: 0,
                  ),
                  child: Text(
                    '10:04:32  03/29/2022',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4C5773),
                      height: 1.1667,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 438,
                width: 100,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    '审核时间：',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4C5773),
                      height: 1.4286,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 120,
                top: 406,
                width: 162,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 0,
                    top: 0,
                    bottom: 0,
                  ),
                  child: Text(
                    'account1',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4C5773),
                      height: 1.1667,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 406,
                width: 100,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    '审核人：',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4C5773),
                      height: 1.4286,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 374,
                width: 100,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    '审核结果：',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4C5773),
                      height: 1.4286,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 120,
                top: 374,
                width: 162,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 0,
                    top: 0,
                    bottom: 0,
                  ),
                  child: Text(
                    '驳回',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEC808D),
                      height: 1.1667,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 120,
                top: 554,
                width: 426,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 0,
                    top: 0,
                    bottom: 0,
                  ),
                  child: Text(
                    '此商品不合规，实物不合规；仓库需要注意检测商品',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF949AAB),
                      height: 1.1667,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 120,
                top: 470,
                width: 426,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 0,
                    top: 0,
                    bottom: 0,
                  ),
                  child: Text(
                    '此商品不合规，实物不合规；仓库需要注意检测商品',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF949AAB),
                      height: 1.1667,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 原因/说明 必填（驳回）。
