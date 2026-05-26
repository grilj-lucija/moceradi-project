import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/shared/widgets/buttons/glass_icon_button.dart';

class ProfileGradient extends StatelessWidget {
  const ProfileGradient({this.height = 560, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = Color.lerp(colors.velocityBlue, colors.enduranceCyan, 0.18)!;
    final innerBlue = Color.lerp(base, Colors.black, 0.16)!;
    final midBlue = Color.lerp(base, Colors.black, 0.6)!;

    return SizedBox(
      height: height,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -1.3),
                  radius: 1.7,
                  colors: [
                    innerBlue,
                    midBlue,
                    colors.background,
                  ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.background.withValues(alpha: 0),
                    colors.background.withValues(alpha: 0),
                    colors.background.withValues(alpha: 0.35),
                    colors.background.withValues(alpha: 0.8),
                    colors.background,
                  ],
                  stops: const [0, 0.4, 0.65, 0.85, 1],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileBackButton extends StatelessWidget {
  const ProfileBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassIconButton(
      icon: Icons.arrow_back,
      tooltip: 'Back',
      onPressed: () => Navigator.maybePop(context),
    );
  }
}
