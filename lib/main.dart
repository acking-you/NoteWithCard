import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:note_app/common_widget.dart';
import 'package:note_app/dialogs.dart';
import 'package:note_app/log.dart';
import 'package:note_app/models/dto.dart' as dto;
import 'package:note_app/models/dto.dart';
import 'package:note_app/prehandle.dart';
import 'package:note_app/screens/book_page.dart';
import 'package:note_app/screens/card_page.dart';
import 'package:note_app/screens/category_page.dart';
import 'package:note_app/screens/save_page.dart';
import 'package:note_app/theme.dart';
import 'package:note_app/util/font_util.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:tray_manager/tray_manager.dart' as stray;
import 'package:window_manager/window_manager.dart';

const appTitle = "Made By L_B__";
const title = 'Note with cards';

var _listen = false;
var _trayOpen = false;

var preHandleStatus = true;
var currentPid = -1;

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
  if (isDesktop) {
    preHandleStatus = await preHandle();
    if (!preHandleStatus) {
      final process = await Process.start(
          'windowsapp_singleton_main.exe', ['$currentPid', title]);
      logger.d(await process.exitCode, currentPid);
      exit(0);
    }
  }
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
    final iconPath = Platform.isWindows
        ? 'images/facebook-fill.ico'
        : 'images/facebook-fill.png';
    await flutter_acrylic.Window.initialize();
    await windowManager.ensureInitialized();
    await windowManager.setIcon(iconPath);
    await windowManager.setTitle(title);
    //如果应用已经被打开,则显示原本的窗口结束自身进程,如果显示失败则不结束进程

    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setSize(const Size(999, 760));
      await windowManager.setMinimumSize(const Size(999, 760));
      await windowManager.center();
      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
    });

    await stray.trayManager.setIcon(iconPath);
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
    ProcessSignal.sigint.watch().listen((event) {
      windowManager.show();
    });
  }
  runApp(const MyApp());
  if (isDesktop) {
    finalHandle();
  }
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
        ),
        ChangeNotifierProvider(create: (_) => CommonData())
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
  const MyHomePage(
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

  static showError(String error) async {
    await displayInfoBar(_shellNavigatorKey.currentState!.context,
        builder: (context, close) {
      return InfoBar(
        title: const Text('出现错误:'),
        content: Text(error),
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
        severity: InfoBarSeverity.error,
      );
    });
  }

  Future<bool> checkBook(String name) async {
    final ret = await Book.getByName(name) == null;
    if (!ret) {
      await showError('书名重复');
    }
    return ret;
  }

  Future<bool> checkCate(String name) async {
    final ret = await dto.Category.getByName(name) == null;
    if (!ret) {
      showError('分类名重复');
    }
    return ret;
  }

  void beforeInit() async {
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
          title: const Text('Cards'),
          body: const SizedBox.shrink(),
          onTap: () {
            appState.state = MyState.kOnContents;
            _rootNavigatorKey.currentContext!
                .goNamed("noteapp", queryParams: {"dest": "card"});
          },
        ),
      )
      ..add(
        PaneItem(
          icon: const Icon(FluentIcons.saved_offline),
          title: const Text('Import&Export'),
          body: const SizedBox.shrink(),
          onTap: () {
            appState.state = MyState.kOnSave;
            _rootNavigatorKey.currentContext!
                .goNamed("noteapp", queryParams: {"dest": "save"});
          },
        ),
      );
    final appData = context.read<AppData>();
    final commonData = context.read<CommonData>();
    await appData.loadAsync();
    final wList = appData.getValuesByKey('work');
    final eList = appData.getValuesByKey('editor');
    if (wList != null && wList.isNotEmpty) commonData.setWorkPath(wList.first);
    if (eList != null && eList.isNotEmpty) {
      commonData.setEditorPath(eList.first);
    }

    if (!_listen) {
      searchController.addListener(() async {
        var text = searchController.text;
        if (text.endsWith('...')) {
          text = text.substring(0, text.length - 3);
        }
        await appData.setContentWithTitle(text);
      });
      _listen = true;
    }

    final navigatorModes = ['top', 'open', 'compact', 'minimal', 'auto'];

    footerItems.add(PaneItem(
        icon: const Icon(FluentIcons.settings),
        body: const SizedBox.shrink(),
        title: const Text('Setting'),
        onTap: () async {
          await showDialog(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return ContentDialog(
                    constraints:
                        const BoxConstraints(maxWidth: 300.0, maxHeight: 400.0),
                    title: Row(
                      children: [
                        const Text('Display Mode'),
                        const Expanded(child: SizedBox()),
                        IconButton(
                            icon: const Icon(FluentIcons.cancel),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ],
                    ),
                    content:
                        Consumer(builder: (context, AppTheme value, child) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(5, (index) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RadioButton(
                                  content: Text(
                                    navigatorModes[index],
                                    style: getFontStyle(size: 18.0),
                                  ),
                                  checked: value.selected == index,
                                  onChanged: (checked) {
                                    if (checked) {
                                      value.selected = index;
                                      switch (navigatorModes[index]) {
                                        case 'top':
                                          value.displayMode =
                                              PaneDisplayMode.top;
                                          break;
                                        case 'open':
                                          value.displayMode =
                                              PaneDisplayMode.open;
                                          break;
                                        case 'compact':
                                          value.displayMode =
                                              PaneDisplayMode.compact;
                                          break;
                                        case 'minimal':
                                          value.displayMode =
                                              PaneDisplayMode.minimal;
                                          break;
                                        case 'auto':
                                          value.displayMode =
                                              PaneDisplayMode.auto;
                                          break;
                                      }
                                    }
                                  }),
                            ),
                          );
                        }),
                      );
                    }));
              });
        }));
    footerItems.add(PaneItem(
        icon: const Icon(FluentIcons.add),
        body: const SizedBox.shrink(),
        title: const Text('New'),
        onTap: () async {
          final mutState = Provider.of<AppState>(context, listen: false);

          if (mutState.state == MyState.kOnContents) {
            await Dialog.editContent(Content(), context);
            return;
          }

          final name =
              mutState.state == MyState.kOnBookMarks ? "bookmark" : "category";
          final appData = Provider.of<AppData>(context, listen: false);

          await showDialog(
            context: context,
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
                    onPressed: () async {
                      final text = booksAddController.text;
                      if (name == "bookmark") {
                        if (await checkBook(text)) {
                          await appData.addBook(dto.Book()..name = text);
                        }
                      } else if (name == "category") {
                        if (await checkCate(text)) {
                          await appData
                              .addCategory(dto.Category()..name = text);
                        }
                      }
                      booksAddController.clear();
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                  ),
                  Button(
                    child: const Text('No'),
                    onPressed: () {
                      booksAddController.clear();
                      Navigator.pop(context);
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
    //如果原本窗口已经存在,则给出提示并结束进程
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (!preHandleStatus) {
        await showTextDialog(
          context,
          title:
              const Text('The program has been running, please do not repeat!'),
          call: () {
            windowManager.destroy();
          },
          noCall: () {
            windowManager.destroy();
          },
        );
      }
    });
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
      case MyState.kOnSave:
        return 3;
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

    return NavigationView(
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
          return DragToMoveArea(
            child: Row(children: [
              const Text(
                appTitle,
                style: TextStyle(fontSize: 15.0, fontFamily: 'Pacifico'),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 420,
              )
            ]),
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
            : Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
            child: const FlutterLogo(
              style: FlutterLogoStyle.markOnly,
              size: 28.0,
              textColor: Colors.white,
              duration: Duration.zero,
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
        autoSuggestBox: Consumer(
          builder: (context, AppData value, child) {
            final v = value.getContentsWithTitle();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: AutoSuggestBox<Content>(
                key: searchKey,
                focusNode: searchFocusNode,
                controller: searchController,
                unfocusedColor: Colors.transparent,
                items: v.map((item) {
                  return AutoSuggestBoxItem<Content>(
                    label: getValidText(item.title, 12),
                    value: item,
                    onSelected: () {
                      appState.state = MyState.kOnContents;
                      context.goNamed("noteapp",
                          queryParams: {"dest": "card", "filter": "title"});
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
            );
          },
        ),
        autoSuggestBoxReplacement: const Icon(FluentIcons.search),
        footerItems: footerItems,
      ),
      onOpenSearch: () {
        searchFocusNode.requestFocus();
      },
    );
  }

  @override
  void onTrayIconMouseDown() {
    // do something, for example pop up the menu
    if (!_trayOpen) {
      windowManager.show();
    } else {
      windowManager.hide();
    }
    _trayOpen = !_trayOpen;
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
                return const BookPage();
              case "category":
                return const CategoryPage();
              case "card":
                return CardPage(
                  filter: state.queryParams['filter'],
                );
              case "save":
                return const SavePage();
              default:
                return const BookPage();
            }
          },
        ),
      ]),
]);
