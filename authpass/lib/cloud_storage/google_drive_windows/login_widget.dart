import 'package:authpass/cloud_storage/google_drive_windows/google_drive_windows_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_async_utils/flutter_async_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';

import 'login_widget/stub.dart'
    if (dart.library.js_util) 'login_widget/web.dart';

final _logger = Logger('login_widget');

class GoogleLoginWidgetWindows extends StatefulWidget {
  const GoogleLoginWidgetWindows({
    super.key,
    required this.onSuccess,
    required this.googleDriveWindowsProvider,
    required this.defaultWidget,
  });

  final GoogleDriveWindowsProvider googleDriveWindowsProvider;
  final VoidCallback onSuccess;
  final Widget defaultWidget;

  @override
  State<GoogleLoginWidgetWindows> createState() =>
      _GoogleLoginWidgetWindowsState();
}

class _GoogleLoginWidgetWindowsState extends State<GoogleLoginWidgetWindows>
    with StreamSubscriberMixin {
  GoogleSignIn get googleSignIn =>
      widget.googleDriveWindowsProvider.googleSignIn;

  bool? _canAccessScopes;

  @override
  void initState() {
    super.initState();
    handleSubscription(googleSignIn.onCurrentUserChanged.listen((event) async {
      _logger.fine('onCurrentUserChanged: ${event?.id}');
      _canAccessScopes =
          await googleSignIn.canAccessScopes(GoogleDriveWindowsProvider.scopes);
      if (_canAccessScopes == true) {
        widget.onSuccess();
      } else {
        setState(() {});
      }
    }));
  }

  Future<void> _checkAuthorization() async {
    if (await googleSignIn.canAccessScopes(GoogleDriveWindowsProvider.scopes)) {
      widget.onSuccess();
    }
    setState(() {
      _canAccessScopes = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (googleSignIn.currentUser == null) {
      final signInButton = buildGoogleSignInButton();
      if (signInButton != null) {
        return signInButton;
      }
      return widget.defaultWidget;
    }
    final loc = AppLocalizations.of(context);
    if (_canAccessScopes == false) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The user has NOT Authorized all required scopes.
          // (Mobile users may never see this button!)
          Text(loc.googleDriveMorePermissionsRequired),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final requestResult = await googleSignIn
                  .requestScopes(GoogleDriveWindowsProvider.scopes);
              setState(() {
                _canAccessScopes = _canAccessScopes;
                if (requestResult) {
                  widget.onSuccess();
                }
              });
              _logger.fine('Requested scopes. result: $requestResult');
            },
            child: Text(loc.googleDriveRequestPermissionButtonLabel),
          ),
        ],
      );
    } else {
      // something is pretty broken.. this state should not happen;
      _logger.severe(
          'curent user is not null but _canAccessScopes is $_canAccessScopes');
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _checkAuthorization();
      });
      return widget.defaultWidget;
    }
  }
}
