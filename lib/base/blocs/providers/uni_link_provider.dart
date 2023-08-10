import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

import 'package:trufi_core/base/pages/about/about.dart';
import 'package:trufi_core/base/pages/feedback/feedback.dart';
import 'package:trufi_core/base/pages/home/home.dart';
import 'package:trufi_core/base/pages/saved_places/saved_places.dart';
import 'package:trufi_core/base/pages/transport_list/transport_list.dart';
import 'package:uni_links/uni_links.dart';

class UniLinkProvider {
  static final UniLinkProvider _singleton = UniLinkProvider._internal();

  factory UniLinkProvider() => _singleton;
  UniLinkProvider._internal();

  bool _isUsedInitialUri = false;
  bool _isRegisteredListening = false;
  StreamSubscription? _streamSubscription;

  void dispose() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  Future<void> runService(BuildContext context) async {
    await _initFirstUri(context: context);
    _registerListening(context: context);
  }

  Future<void> _initFirstUri({
    required BuildContext context,
  }) async {
    if (!_isUsedInitialUri) {
      _isUsedInitialUri = true;
      try {
        final initialURI = await getInitialUri();
        if (initialURI != null) {
          _parseUniLink(context: context, uri: initialURI);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  void _registerListening({
    required BuildContext context,
  }) {
    if (!kIsWeb && !_isRegisteredListening) {
      _streamSubscription = uriLinkStream.listen((Uri? uri) {
        _parseUniLink(context: context, uri: uri);
      }, onError: (e) {
        debugPrint(e.toString());
      });
      _isRegisteredListening = true;
    }
  }

  void _parseUniLink({
    required BuildContext context,
    Uri? uri,
  }) {
    if (uri != null) {
      switch ('/${uri.pathSegments.last}') {
        case HomePage.route:
          _cleanNavigatorStore(
            context,
            () => Routemaster.of(context).push(
              HomePage.route,
              queryParameters: uri.queryParameters,
            ),
          );
          break;
        case TransportList.route:
          _cleanNavigatorStore(
            context,
            () {
              Routemaster.of(context).push(
                TransportList.route,
                queryParameters: uri.queryParameters,
              );
            },
          );
          break;
        case SavedPlacesPage.route:
          _cleanNavigatorStore(
            context,
            () => Routemaster.of(context).push(SavedPlacesPage.route),
          );
          break;
        case FeedbackPage.route:
          _cleanNavigatorStore(
            context,
            () => Routemaster.of(context).push(FeedbackPage.route),
          );
          break;
        case AboutPage.route:
          _cleanNavigatorStore(
            context,
            () => Routemaster.of(context).push(AboutPage.route),
          );
          break;
        default:
      }
    }
  }

  void _cleanNavigatorStore(BuildContext context, Function newNavigator) {
    while (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    newNavigator();
  }
}
