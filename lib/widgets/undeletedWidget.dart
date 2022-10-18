import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class UnDeletetedWidget extends StatefulWidget {
  final Future future;
  final AsyncWidgetBuilder builder;
  const UnDeletetedWidget({super.key, required this.future, required this.builder});

  @override
  State<UnDeletetedWidget> createState() => _UnDeletetedWidgetState();
}

class _UnDeletetedWidgetState extends State<UnDeletetedWidget> with AutomaticKeepAliveClientMixin<UnDeletetedWidget> {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: widget.future,
      builder: widget.builder
      );
  }
}