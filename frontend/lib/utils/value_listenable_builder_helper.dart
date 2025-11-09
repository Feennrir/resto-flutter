import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class MultiValueListenableBuilder extends StatelessWidget {

  final List<ValueListenable> valueListenableList;
  final Widget Function(BuildContext) builder;

  const MultiValueListenableBuilder({
    required this.valueListenableList,
    required this.builder,
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(valueListenableList),
      builder: (BuildContext ctx, Widget? _) => builder(ctx),
    );
  }
}