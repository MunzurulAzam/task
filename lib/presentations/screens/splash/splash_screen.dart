import 'package:task01/core/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task01/core/constants/assets/app_images.dart';
import 'package:task01/logic/providers/splash_screen_provider/splash_screen_riverpod_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(splashNotifierProvider);

    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Image.asset(AppImages.logo, height: getScreenHeight(1), width: getScreenWidth(1)),
        ),
      ),
    );
  }
}
