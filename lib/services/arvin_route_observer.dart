import 'package:flutter/material.dart';

/// Single app-wide route observer used for lightweight screen refreshes.
/// It does not own data or storage; screens re-read their existing canonical
/// stores when they become visible again.
final RouteObserver<ModalRoute<void>> arvinRouteObserver =
    RouteObserver<ModalRoute<void>>();
