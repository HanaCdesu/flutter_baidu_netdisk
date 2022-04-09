import 'package:flutter/material.dart';

class IroListCard extends StatefulWidget {
  IroListCard(
      {Key? key,
      required this.child,
      required this.animationController,
      required this.indexcont,
      this.matrix = const [10, 50, 100],
      this.reload = true})
      : super(key: key);
  final Widget child;
  final AnimationController animationController;
  final double indexcont;
  final List<int> matrix;
  final bool reload;

  @override
  _IroListCardState createState() => _IroListCardState(animationController);
}

class _IroListCardState extends State<IroListCard>
    with TickerProviderStateMixin {
  final AnimationController animationController;

  _IroListCardState(this.animationController);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.reload
        ? animationController.forward(from: 0)
        : animationController.forward());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(widget.indexcont, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, _) {
        return FadeTransition(
          opacity: animation,
          child: new Transform(
            transform: Matrix4.translationValues(
              widget.matrix[0] * (1.0 - animation.value),
              widget.matrix[1] * (1.0 - animation.value),
              widget.matrix[2] * (1.0 - animation.value),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
