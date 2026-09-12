// 审核（原因/说明 选填，对应 通过）。
import 'package:flutter/material.dart';

class AuditFormOptionalDialog extends StatelessWidget {
  const AuditFormOptionalDialog({super.key});

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
                left: 268,
                top: 555,
                width: 70,
                height: 30,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Color(0xFFF2F2F2), width: 1),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 21,
                        top: 7,
                        width: 28,
                        height: 17,
                        child: Text(
                          '取消',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                          ),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 362,
                top: 555,
                width: 70,
                height: 30,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF4C5773),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 21,
                        top: 7,
                        width: 28,
                        height: 17,
                        child: Text(
                          '确定',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFFFFFFF),
                          ),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                    '审核\n',
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
                left: 120,
                top: 79,
                width: 108,
                height: 17,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        width: 49,
                        height: 17,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 2,
                                width: 13,
                                height: 13,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 3,
                                        top: 3,
                                        width: 7,
                                        height: 7,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 21,
                                top: 0,
                                width: 28,
                                height: 17,
                                child: Text(
                                  '通过',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF949AAB),
                                  ),
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 59,
                        top: 0,
                        width: 49,
                        height: 17,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 2,
                                width: 13,
                                height: 13,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 3,
                                        top: 3,
                                        width: 7,
                                        height: 7,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 21,
                                top: 0,
                                width: 28,
                                height: 17,
                                child: Text(
                                  '驳回',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF949AAB),
                                  ),
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 88,
                width: 120,
                height: 30,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 8,
                    bottom: 8,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 118,
                width: 120,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    '原因/说明(选)：',
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
                top: 118,
                width: 560,
                height: 100,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(0),
                            border: Border.all(
                              color: Color(0xFFD7D7D7),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                            left: 8,
                            right: 8,
                            top: 8,
                            bottom: 8,
                          ),
                          child: Text(
                            '请输入～(外部可见)',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF949AAB),
                            ),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 480,
                        top: 70,
                        width: 80,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(
                            left: 8,
                            right: 8,
                            top: 8,
                            bottom: 8,
                          ),
                          child: Text(
                            '0 / 255',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4C5773),
                              height: 1.6667,
                            ),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 338,
                width: 120,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 8,
                    bottom: 8,
                  ),
                  child: Text(
                    '内部备注(选)：',
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
                top: 338,
                width: 560,
                height: 100,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(0),
                            border: Border.all(
                              color: Color(0xFFD7D7D7),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                            left: 8,
                            right: 8,
                            top: 8,
                            bottom: 8,
                          ),
                          child: Text(
                            '请输入～(备注仅当前平台可查看)',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF949AAB),
                            ),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 480,
                        top: 70,
                        width: 80,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(
                            left: 8,
                            right: 8,
                            top: 8,
                            bottom: 8,
                          ),
                          child: Text(
                            '0 / 255',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4C5773),
                              height: 1.6667,
                            ),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 234,
                width: 120,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 8,
                    bottom: 8,
                  ),
                  child: Text(
                    '图片(选)：',
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
                left: 200,
                top: 234,
                width: 72,
                height: 72,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: Color(0xFFD7D7D7), width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.w700,
                      height: 1.1111,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 280,
                top: 234,
                width: 360,
                height: 72,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '1.单张大小不超过20M,支持: .jpg 、.png 、.jpeg\n2.建议您上传宽750*高度2000以内的图片不超过10张\n3.图片要求拍摄清晰、实物展示，无边框、无文字、无水印\n4.仅内部可见',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF949AAB),
                      height: 1.3333,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 25,
                top: 322,
                width: 650,
                height: 0,
                child: Container(
                  width: 650,
                  height: 1,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFAAAAAA), width: 1),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 454,
                width: 120,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 8,
                    bottom: 8,
                  ),
                  child: Text(
                    '图片(选)：',
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
                left: 200,
                top: 454,
                width: 72,
                height: 72,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: Color(0xFFD7D7D7), width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.w700,
                      height: 1.1111,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 120,
                top: 454,
                width: 72,
                height: 72,
                child: SizedBox.shrink(),
              ),
              Positioned(
                left: 280,
                top: 454,
                width: 360,
                height: 72,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '1.单张大小不超过20M,支持: .jpg 、.png 、.jpeg\n2.建议您上传宽750*高度2000以内的图片不超过10张\n3.图片要求拍摄清晰、实物展示，无边框、无文字、无水印\n4.仅内部可见',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF949AAB),
                      height: 1.3333,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Positioned(
                left: 120,
                top: 234,
                width: 72,
                height: 72,
                child: SizedBox.shrink(),
              ),
              Positioned(
                left: 718,
                top: 354,
                width: 400,
                height: 200,
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
                        left: 310,
                        top: 151,
                        width: 70,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Color(0xFFF2F2F2),
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 21,
                                top: 7,
                                width: 28,
                                height: 17,
                                child: Text(
                                  '取消',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF949AAB),
                                  ),
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 228,
                        top: 151,
                        width: 70,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF4C5773),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 21,
                                top: 7,
                                width: 28,
                                height: 17,
                                child: Text(
                                  '确定',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 33,
                        width: 400,
                        height: 67,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 8,
                            bottom: 8,
                          ),
                          child: Text(
                            '确认后不可反审，请仔细审查后确认！！！',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4C5773),
                              height: 1.4286,
                            ),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                    ],
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

// 审核详情（查看）。
