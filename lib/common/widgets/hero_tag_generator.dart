import 'package:flutter/widgets.dart';

class HeroTagGenerator extends StatefulWidget {
  final Widget Function(BuildContext context, String heroTag) builder;
  const HeroTagGenerator({super.key, required this.builder});

  @override
  State<HeroTagGenerator> createState() => _HeroTagGeneratorState();
}

class _HeroTagGeneratorState extends State<HeroTagGenerator> {
  static int _idCounter = 0;
  late final String _heroTag;

  @override
  void initState() {
    super.initState();
    _idCounter++;
    _heroTag = 'hero_tag_$_idCounter';
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _heroTag);
  }
}
