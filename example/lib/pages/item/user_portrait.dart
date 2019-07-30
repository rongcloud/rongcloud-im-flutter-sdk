import 'package:flutter/material.dart';

class Portrait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          color: Colors.yellow),
      height: 40,
      width: 40,
      child: Image.network(
        'http://n.sinaimg.cn/sports/2_img/upload/cf0d0fdd/107/w1024h683/20181128/pKtl-hphsupx4744393.jpg',
        fit: BoxFit.fill,
      ),
    );
  }
}
