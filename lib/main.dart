import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as mt;
import 'package:go_router/go_router.dart';
import 'package:note_app/screens/book_page.dart';
import 'package:note_app/screens/card_page.dart';
import 'package:note_app/screens/category_page.dart';
import 'package:note_app/screens/home_page.dart';
import 'package:note_app/theme.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:tray_manager/tray_manager.dart' as stray;
import 'package:window_manager/window_manager.dart';

const appTitle = "NoteApp From L_B__";

/// Checks if the current environment is a desktop environment.
bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if it's not on the web, windows or android, load the accent color
  if (!kIsWeb &&
      [
        TargetPlatform.windows,
        TargetPlatform.android,
      ].contains(defaultTargetPlatform)) {
    SystemTheme.accentColor.load();
  }

  if (isDesktop) {
    await stray.trayManager.setIcon(Platform.isWindows
        ? 'images/facebook-fill.ico'
        : 'images/facebook-fill.png');
    stray.Menu menu = stray.Menu(items: [
      stray.MenuItem(
        key: 'show_window',
        label: 'Show Window',
      ),
      stray.MenuItem.separator(),
      stray.MenuItem(
        key: 'exit_app',
        label: 'Exit App',
      ),
    ]);
    stray.trayManager.setContextMenu(menu);
    await flutter_acrylic.Window.initialize();
    await windowManager.ensureInitialized();
    windowManager.setIcon("images/facebook-fill.ico");
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setSize(const Size(950, 750));
      await windowManager.setMinimumSize(const Size(850, 600));
      await windowManager.center();
      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // private navigators

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppTheme(),
        ),
        ChangeNotifierProvider(
          create: (_) => AppState(),
        ),
        ChangeNotifierProvider(
          create: (_) => AppData(),
        )
      ],
      builder: (context, _) {
        final appTheme = context.watch<AppTheme>();
        // appTheme.setEffect(WindowEffect.tabbed, context);
        return FluentApp.router(
          title: appTitle,
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          color: appTheme.color,
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen() ? 2.0 : 0.0,
            ),
          ),
          theme: FluentThemeData(
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen() ? 2.0 : 0.0,
            ),
          ),
          locale: appTheme.locale,
          builder: (context, child) {
            return Directionality(
              textDirection: appTheme.textDirection,
              child: NavigationPaneTheme(
                data: NavigationPaneThemeData(
                  backgroundColor: appTheme.windowEffect !=
                          flutter_acrylic.WindowEffect.disabled
                      ? Colors.transparent
                      : null,
                ),
                child: child!,
              ),
            );
          },
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          routeInformationProvider: router.routeInformationProvider,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage(
      {Key? key,
      required this.child,
      required this.shellContext,
      required this.state})
      : super(key: key);
  final Widget child;
  final BuildContext? shellContext;
  final GoRouterState state;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with WindowListener, stray.TrayListener {
  final viewKey = GlobalKey(debugLabel: 'Navigation View Key');
  final searchKey = GlobalKey(debugLabel: 'Search Bar Key');
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();
  final booksAddController = TextEditingController();
  final List<NavigationPaneItem> footerItems = [];
  final List<NavigationPaneItem> originnalItems = [];

  void beforeInit() {
    final appState = _rootNavigatorKey.currentContext!.watch<AppState>();
    originnalItems
      ..add(
        PaneItem(
          icon: const Icon(FluentIcons.diet_plan_notebook),
          title: const Text('Bookmarks'),
          body: const SizedBox.shrink(),
          onTap: () {
            appState.state = MyState.kOnBookMarks;
            _rootNavigatorKey.currentContext!
                .goNamed("noteapp", queryParams: {"dest": "book"});
          },
        ),
      )
      ..add(
        PaneItem(
          icon: const Icon(FluentIcons.auto_fill_template),
          title: const Text('Categories'),
          body: const SizedBox.shrink(),
          onTap: () {
            appState.state = MyState.kOnCategories;
            _rootNavigatorKey.currentContext!
                .goNamed("noteapp", queryParams: {"dest": "category"});
          },
        ),
      )
      ..add(
        PaneItem(
          icon: const Icon(FluentIcons.collapse_content),
          title: const Text('Contents'),
          body: const SizedBox.shrink(),
          onTap: () {
            appState.state = MyState.kOnContents;
            _rootNavigatorKey.currentContext!
                .goNamed("noteapp", queryParams: {"dest": "card"});
          },
        ),
      );

    footerItems.add(PaneItem(
        icon: const Icon(FluentIcons.add),
        body: const SizedBox.shrink(),
        title: const Text('New Bookmark or Category'),
        onTap: () {
          var curCtx = _rootNavigatorKey.currentState!.context;
          final mutState = Provider.of<AppState>(curCtx, listen: false);
          final name =
              mutState.state == MyState.kOnBookMarks ? "book" : "category";
          showDialog(
            context: curCtx,
            builder: (_) {
              return ContentDialog(
                title: Text("New $name"),
                content: Card(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4.0)),
                  child: InfoLabel(
                    label: "Enter your $name name:",
                    child: TextBox(
                      placeholder: '$name name',
                      expands: false,
                      controller: booksAddController,
                    ),
                  ),
                ),
                actions: [
                  FilledButton(
                    child: const Text('Ok'),
                    onPressed: () {
                      final text = booksAddController.text;
                      booksAddController.clear();
                      Navigator.pop(curCtx);
                    },
                  ),
                  Button(
                    child: const Text('No'),
                    onPressed: () {
                      booksAddController.clear();
                      Navigator.pop(curCtx);
                    },
                  ),
                ],
              );
            },
          );
        }));
  }

  @override
  void initState() {
    windowManager.addListener(this);
    stray.trayManager.addListener(this);
    super.initState();
    beforeInit();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final appState = context.watch<AppState>();
    switch (appState.state) {
      case MyState.kOnBookMarks:
        return 0;
      case MyState.kOnCategories:
        return 1;
      case MyState.kOnContents:
        return 2;
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    stray.trayManager.removeListener(this);
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    final theme = FluentTheme.of(context);
    final appState = context.watch<AppState>();

    return mt.SelectionArea(
      child: NavigationView(
        key: viewKey,
        appBar: NavigationAppBar(
          automaticallyImplyLeading: false,
          title: () {
            if (kIsWeb) {
              return const Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(appTitle),
              );
            }
            return const DragToMoveArea(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(appTitle),
              ),
            );
          }(),
          actions: kIsWeb
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: ToggleSwitch(
                    content: const Text('Dark Mode'),
                    checked: FluentTheme.of(context).brightness.isDark,
                    onChanged: (v) {
                      if (v) {
                        appTheme.mode = ThemeMode.dark;
                      } else {
                        appTheme.mode = ThemeMode.light;
                      }
                    },
                  ),
                )
              : DragToMoveArea(
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8.0),
                      child: ToggleSwitch(
                        content: const Text('Dark Mode'),
                        checked: FluentTheme.of(context).brightness.isDark,
                        onChanged: (v) {
                          if (v) {
                            appTheme.mode = ThemeMode.dark;
                          } else {
                            appTheme.mode = ThemeMode.light;
                          }
                        },
                      ),
                    ),
                    const WindowButtons(),
                  ]),
                ),
        ),
        paneBodyBuilder: (item, child) {
          final name =
              item?.key is ValueKey ? (item!.key as ValueKey).value : null;
          return FocusTraversalGroup(
            key: ValueKey('body$name'),
            child: widget.child,
          );
        },
        pane: NavigationPane(
          selected: _calculateSelectedIndex(context),
          header: SizedBox(
            height: kOneLineTileHeight,
            child: ShaderMask(
              shaderCallback: (rect) {
                final color = appTheme.color.defaultBrushFor(
                  theme.brightness,
                );
                return LinearGradient(
                  colors: [
                    color,
                    color,
                  ],
                ).createShader(rect);
              },
              child: Image.asset(
                appTheme.mode == ThemeMode.light
                    ? "images/react-light.png"
                    : "images/react-light.png",
                // cacheHeight: 60,
                // cacheWidth: 60,
              ),
            ),
          ),
          displayMode: appTheme.displayMode,
          indicator: () {
            switch (appTheme.indicator) {
              case NavigationIndicators.end:
                return const EndNavigationIndicator();
              case NavigationIndicators.sticky:
              default:
                return const StickyNavigationIndicator();
            }
          }(),
          items: originnalItems,
          autoSuggestBox: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: AutoSuggestBox(
              key: searchKey,
              focusNode: searchFocusNode,
              controller: searchController,
              unfocusedColor: Colors.transparent,
              items: originnalItems.whereType<PaneItem>().map((item) {
                assert(item.title is Text);
                final text = (item.title as Text).data!;
                return AutoSuggestBoxItem(
                  label: text,
                  value: text,
                  onSelected: () {
                    item.onTap?.call();
                    searchController.clear();
                  },
                );
              }).toList(),
              trailingIcon: IgnorePointer(
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(FluentIcons.search),
                ),
              ),
              placeholder: 'Search',
            ),
          ),
          autoSuggestBoxReplacement: const Icon(FluentIcons.search),
          footerItems:
              appState.state != MyState.kOnContents ? footerItems : const [],
        ),
        onOpenSearch: () {
          searchFocusNode.requestFocus();
        },
      ),
    );
  }

  @override
  void onTrayIconMouseDown() {
    // do something, for example pop up the menu
    windowManager.show();
  }

  @override
  void onTrayIconRightMouseDown() {
    stray.trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseUp() {
    // do something
  }

  @override
  void onTrayMenuItemClick(stray.MenuItem menuItem) {
    if (menuItem.key == 'show_window') {
      // do something
      windowManager.show();
    } else if (menuItem.key == 'exit_app') {
      // do something
      windowManager.destroy();
    }
  }

  @override
  void onWindowClose() async {
    windowManager.hide();
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FluentThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(navigatorKey: _rootNavigatorKey, routes: [
  ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (ctx, state, child) {
        return MyHomePage(
          shellContext: ctx,
          state: state,
          child: child,
        );
      },
      routes: [
        /// Home
        GoRoute(
          path: '/',
          name: 'noteapp',
          builder: (context, state) {
            switch (state.queryParams["dest"]) {
              case "book":
                return BookPage();
              case "category":
                return CategoryPage();
              case "card":
                return CardPage();

              default:
                return const HomePage();
            }
          },
        ),
      ]),
]);
