import 'package:flutter/cupertino.dart';

class CustomTabBarViewScrollPhysics extends PageScrollPhysics {
  const CustomTabBarViewScrollPhysics({super.parent});

  @override
  CustomTabBarViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomTabBarViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    // 处理越界回弹
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    
    if (position.viewportDimension <= 0.0) {
      return super.createBallisticSimulation(position, velocity);
    }

    final Tolerance tolerance = toleranceFor(position);
    
    // 计算当前所处的逻辑页码
    final double page = position.pixels / position.viewportDimension;
    final double currentPage = page.roundToDouble();

    // 根据初速度推测目标页，强制截断到相邻的上一页或下一页
    double targetPage = currentPage;
    if (velocity < -tolerance.velocity) {
      targetPage = currentPage - 1.0;
    } else if (velocity > tolerance.velocity) {
      targetPage = currentPage + 1.0;
    }

    // 强行把目标像素锁定在整数页上
    final double targetPixels = targetPage * position.viewportDimension;
    
    if (targetPixels != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        targetPixels,
        velocity,
        tolerance: tolerance,
      );
    }
    return null;
  }

  // 使用过阻尼弹簧（Overdamped Spring）彻底消除惯性过冲
  // 质量 1, 刚度 800, 临界阻尼约 56。这里阻尼设为 100，确保绝对不越界
  @override
  SpringDescription get spring => const SpringDescription(
    mass: 1,
    stiffness: 800,
    damping: 100,
  );
  
  // 限制最大初始滑动速度，防止用力过猛导致的底层状态异常
  @override
  double get maxFlingVelocity => 2500.0;
}