import 'package:flutter/widgets.dart';

class HeroTagGenerator extends StatefulWidget {
  final Widget Function(BuildContext context, String heroTag) builder;
  const HeroTagGenerator({super.key, required this.builder});

  @override
  State<HeroTagGenerator> createState() => _HeroTagGeneratorState();
}

class _HeroTagGeneratorState extends State<HeroTagGenerator> {
  late final String _heroTag;

  @override
  void initState() {
    super.initState();
    _heroTag = UniqueKey().toString();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _heroTag);
  }
}
