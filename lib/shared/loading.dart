import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: const Center(
        child: SpinKitPouringHourGlassRefined(
          color: Colors.white,
          size: 80.0,
        ),
      ),
    );
  }
}