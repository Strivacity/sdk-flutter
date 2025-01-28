// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

/// Represents the context for the login process.
class LoginContext {
  /// Indicates whether a form submission is in progress.
  bool loading = false;

  /// Stores the state of the forms.
  Map<String, Map<String, dynamic>> formContexts = {};

  /// Stores the messages for the forms.
  Map<String, Map<dynamic, dynamic>> messageContexts = {};

  /// Represents the current state of the login flow.
  LoginFlowState state = LoginFlowState();

  /// A function to submit a form with the given form ID.
  Future<void> Function(String formId) submitForm;

  /// A function to trigger the fallback process with an optional hosted URL.
  void Function([String? hostedUrl]) triggerFallback;

  /// Creates a new instance of [LoginContext].
  ///
  /// The [submitForm] and [triggerFallback] parameters are required.
  LoginContext({required this.submitForm, required this.triggerFallback});

  /// Sets the form state for the given [formId] and [widgetId] with the provided [value].
  void setFormState(String formId, String widgetId, dynamic value) {
    if (value is String && value.isEmpty) {
      value = null;
    }

    formContexts[formId]![widgetId] = value;
  }

  /// Sets the message for the given [formId] and [widgetId] with the provided [value].
  void setMessage(String formId, String widgetId, String? value) {
    messageContexts[formId]![widgetId] = value;
  }
}

/// A widget that renders the login process.
class LoginRenderer extends StatefulWidget {
  /// The Strivacity SDK instance.
  final StrivacitySDK sdk;

  /// Optional OIDC parameters.
  final OidcParams? params;

  /// The factory for creating view components.
  final ViewFactory viewFactory;

  /// Callback function to be called upon successful login.
  final FutureOr<void> Function(IdTokenClaims? idTokenClaims)? onLogin;

  /// Callback function to be called when an error occurs.
  final FutureOr<void> Function(dynamic e, dynamic stackTrace)? onError;

  /// Callback function to be called when a fallback is triggered.
  final FutureOr<void> Function(Uri uri, String? errorMessage)? onFallback;

  /// Callback function to be called for global messages.
  final FutureOr<void> Function(String text)? onGlobalMessage;

  /// Creates a new instance of [LoginRenderer].
  ///
  /// The [sdk] and [viewFactory] parameters are required.
  const LoginRenderer({
    super.key,
    this.params,
    this.onLogin,
    this.onError,
    this.onFallback,
    this.onGlobalMessage,
    required this.sdk,
    required this.viewFactory,
  });

  @override
  State<LoginRenderer> createState() => _LoginRendererState();
}

class _LoginRendererState extends State<LoginRenderer> {
  bool _initialized = false;
  late LoginHandler _loginHandler;
  late LoginContext _loginContext;

  @override
  void initState() {
    super.initState();

    _loginHandler = widget.sdk.login(widget.params);
    _loginContext = LoginContext(submitForm: _submitForm, triggerFallback: _triggerFallback);

    _init();
  }

  Future<void> _init() async {
    try {
      final data = await _loginHandler.startSession();
      final state = LoginFlowState.fromJson(data);

      if (await widget.sdk.isAuthenticated) {
        widget.onLogin?.call(widget.sdk.idTokenClaims);
      } else {
        if (state.screen != _loginContext.state.screen) {
          _loginContext.formContexts = {};
          _loginContext.messageContexts = {};

          for (final formId in state.forms!.map((form) => form.id)) {
            _loginContext.formContexts[formId] = {};
            _loginContext.messageContexts[formId] = {};
          }
        }

        state.messages?.forEach((formId, messages) {
          if (formId == 'global') {
            widget.onGlobalMessage?.call(messages['global']?.text ?? '');
          } else {
            _loginContext.messageContexts[formId] = messages.map((widgetId, message) => MapEntry(widgetId, message.text));
          }
        });

        setState(() {
          _loginContext.state = state;
          _initialized = true;
        });
      }
    } on FallbackError catch (e) {
      _onFallback(e);
    } catch (e, stackTrace) {
      _onError(e, stackTrace);
    }
  }

  Future<void> _submitForm(String formId) async {
    try {
      setState(() {
        _loginContext.loading = true;
      });

      final data = await _loginHandler.submitForm(formId, _convertFormContext(_loginContext.formContexts[formId]));

      if (await widget.sdk.isAuthenticated) {
        widget.onLogin?.call(widget.sdk.idTokenClaims);
      } else {
        final state = _loginContext.state.update(LoginFlowState.fromJson(data));

        if (state.screen != _loginContext.state.screen) {
          _loginContext.formContexts = {};
          _loginContext.messageContexts = {};

          for (final formId in state.forms!.map((form) => form.id)) {
            _loginContext.formContexts[formId] = {};
            _loginContext.messageContexts[formId] = {};
          }
        }

        state.messages?.forEach((id, messages) {
          if (id == 'global') {
            widget.onGlobalMessage?.call(messages['global']?.text ?? '');
          } else {
            _loginContext.messageContexts[id] = messages.map((widgetId, message) => MapEntry(widgetId, message.text));
          }
        });

        setState(() {
          _loginContext.state = state;
          _loginContext.loading = false;
        });
      }
    } on FallbackError catch (e) {
      _onFallback(e);
    } catch (e, stackTrace) {
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      _onError(e, stackTrace);
    }
  }

  void _triggerFallback([String? hostedUrl, String? message]) {
    hostedUrl ??= _loginContext.state.hostedUrl;

    if (hostedUrl == null) {
      throw Exception('No hosted URL provided');
    }
    if (widget.onFallback == null) {
      throw Exception('No fallback handler provided');
    }

    widget.onFallback?.call(Uri.parse(hostedUrl), message);
  }

  List<Widget> _renderComponents(List<dynamic> items) {
    return items.map<Widget>((item) {
      if (item['type'] == 'widget') {
        final f = _loginContext.state.forms?.firstWhere((form) => form.id == item['formId']);
        final w = f?.widgets.firstWhere((widget) => widget.id == item['widgetId']) as BaseWidgetModel?;

        if (f == null || w == null) {
          _triggerFallback(_loginContext.state.hostedUrl!, 'Form or widget not found');
          return Text('');
        }

        switch (w.type) {
          case 'checkbox':
            return widget.viewFactory
                .getCheckboxWidget(key: Key('${f.id}|${w.id}'), formId: f.id, loginContext: _loginContext, config: w as CheckboxWidgetModel);
          case 'date':
            return widget.viewFactory.getDateWidget(key: Key('${f.id}|${w.id}'), formId: f.id, loginContext: _loginContext, config: w as DateWidgetModel);
          case 'input':
            return widget.viewFactory.getInputWidget(key: Key('${f.id}|${w.id}'), formId: f.id, loginContext: _loginContext, config: w as InputWidgetModel);
          case 'multiSelect':
            return widget.viewFactory
                .getMultiSelectWidget(key: Key('${f.id}|${w.id}'), formId: f.id, loginContext: _loginContext, config: w as MultiSelectWidgetModel);
          case 'passcode':
            return widget.viewFactory
                .getPasscodeWidget(key: Key('${f.id}|${w.id}'), formId: f.id, loginContext: _loginContext, config: w as PasscodeWidgetModel);
          case 'password':
            return widget.viewFactory
                .getPasswordWidget(key: Key('${f.id}|${w.id}'), formId: f.id, loginContext: _loginContext, config: w as PasswordWidgetModel);
          case 'phone':
            return widget.viewFactory.getPhoneWidget(key: Key('${f.id}|${w.id}'), formId: f.id, loginContext: _loginContext, config: w as PhoneWidgetModel);
          case 'select':
            return widget.viewFactory.getSelectWidget(key: Key('${f.id}|${w.id}'), formId: f.id, loginContext: _loginContext, config: w as SelectWidgetModel);
          case 'submit':
            return widget.viewFactory.getSubmitWidget(key: Key('${f.id}|${w.id}'), formId: f.id, loginContext: _loginContext, config: w as SubmitWidgetModel);
          case 'static':
            return widget.viewFactory.getStaticWidget(key: Key('${f.id}|${w.id}'), config: w as StaticWidgetModel);
          default:
            _triggerFallback(_loginContext.state.hostedUrl!, 'Unknown widget type: ${w.type}');
            return Text('');
        }
      } else if (item['type'] == 'vertical' || item['type'] == 'horizontal') {
        return widget.viewFactory.getLayoutWidget(key: UniqueKey(), type: item['type'], children: _renderComponents(item['items']));
      } else {
        _triggerFallback(_loginContext.state.hostedUrl!, 'Unknown item type: ${item['type']}');
        return Text('');
      }
    }).toList();
  }

  void _onFallback(FallbackError e) {
    if (widget.onFallback == null) {
      throw Exception('No fallback handler provided');
    }
    if (e.uri == null && _loginContext.state.hostedUrl == null) {
      throw Exception('No fallback uri available');
    }

    widget.onFallback?.call(e.uri ?? Uri.parse(_loginContext.state.hostedUrl!), e.toString());
  }

  void _onError(dynamic e, dynamic stackTrace) {
    if (_loginContext.state.hostedUrl != null && widget.onFallback != null) {
      widget.onFallback?.call(Uri.parse(_loginContext.state.hostedUrl!), e.toString());
    } else {
      widget.onError?.call(e, stackTrace);
    }
  }

  Map<String, dynamic> _convertFormContext(Map<String, dynamic>? flatMap) {
    final Map<String, dynamic> nestedMap = {};

    flatMap?.forEach((key, value) {
      List<String> keys = key.split('.');
      Map<dynamic, dynamic> currentMap = nestedMap;

      for (int i = 0; i < keys.length; i++) {
        if (i == keys.length - 1) {
          currentMap[keys[i]] = value;
        } else {
          if (!currentMap.containsKey(keys[i])) {
            currentMap[keys[i]] = {};
          }

          currentMap = currentMap[keys[i]] as dynamic;
        }
      }
    });

    return nestedMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _initialized
          ? widget.viewFactory.getContainerWidget(children: _renderComponents(_loginContext.state.layout?.items ?? <dynamic>[]))
          : widget.viewFactory.getLoadingWidget(),
    );
  }
}
