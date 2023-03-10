import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mt;
import 'package:note_app/dialogs.dart';
import 'package:note_app/screens/book_page.dart';
import 'package:note_app/screens/category_page.dart';
import 'package:note_app/theme.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/link.dart';

import '../util/font_util.dart';

class Content {
  String title;
  String? detail;
  Category category;
  Book book;
  Content(this.title, this.category, this.book);
  Content.create()
      : title = "",
        category = Category("", 0),
        book = Book("name");
}

final kOnBoxHover = BoxDecoration(
    // border: Border.all(color: Colors.grey[30]),
    color: Color.fromARGB(255, 249, 249, 248),
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: [
      BoxShadow(
        color: mt.Colors.grey.shade400,
        blurRadius: 20,
      ),
    ]);

final kOnBoxNormal = BoxDecoration(
    color: Color.fromARGB(255, 249, 249, 249),
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: [
      BoxShadow(
        color: mt.Colors.grey.shade400,
        blurRadius: 5,
      ),
    ]);

final kOnDarkBoxHover = BoxDecoration(
    // border: Border.all(color: Colors.grey[30]),
    color: Colors.grey[170],
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: [
      BoxShadow(
        color: mt.Colors.grey.shade400,
        blurRadius: 20,
      ),
    ]);

final kOnDarkBoxNormal = BoxDecoration(
    color: Colors.grey[170],
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: [
      BoxShadow(
        color: mt.Colors.grey.shade400,
        blurRadius: 5,
      ),
    ]);

final _mockList = [
  Content("激动撒范德萨范德萨分大苏打撒法撒旦范德萨范德萨范德萨分十大幅度萨芬十大犯得上大师傅士大夫就看见即可",
      Category("飞洒发范德萨发撒的就看见j1", 10), Book("计算机")),
  Content("计算机网络", Category("分类2", 11), Book("计算机1")),
  Content("计算机网络", Category("分类2", 11), Book("计算机2")),
  Content("计算机网络", Category("分类2", 11), Book("计算机3")),
];

class CardPage extends StatefulWidget {
  CardPage({Key? key}) : super(key: key);

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Your Cards'),
        commandBar: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Link(
            uri: Uri.parse('https://acking-you.github.io'),
            builder: (context, open) => Tooltip(
              message: 'Source code',
              child: IconButton(
                icon: const Icon(FluentIcons.open_source, size: 24.0),
                onPressed: open,
              ),
            ),
          ),
        ]),
      ),
      content: GridView.builder(
        padding: EdgeInsetsDirectional.only(
          start: PageHeader.horizontalPadding(context),
          end: PageHeader.horizontalPadding(context),
        ),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          mainAxisSpacing: 25.0,
          crossAxisSpacing: 25.0,
        ),
        itemCount: _mockList.length,
        itemBuilder: (context, index) {
          final e = _mockList.elementAt(index);
          return HoverButton(
              onPressed: () async {
                final copyText = 'FluentIcons.$e';
              },
              cursor: SystemMouseCursors.copy,
              builder: (context, states) {
                return FocusBorder(
                  focused: states.isFocused,
                  renderOutside: false,
                  child: RepaintBoundary(
                    child: Stack(children: [
                      AnimatedContainer(
                          duration:
                              FluentTheme.of(context).slowAnimationDuration,
                          height: 250,
                          width: 250,
                          decoration: getBoxDecration(context, states)),
                      Center(
                        child: getCenterContent(e),
                      ),
                      if (states.isHovering)
                        Positioned(
                            right: 15.0,
                            bottom: 10.0,
                            child: getHoverButton(e, context)),
                      if (states.isHovering)
                        Positioned(
                            top: 1, right: 1, child: getHoverIcon(context)),
                    ]),
                  ),
                );
              });
        },
      ),
    );
  }

  Widget getCenterContent(Content e) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 50.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            leading: Icon(FluentIcons.title),
            title: Text(getValidText(e.title, 6)),
          ),
          ListTile(
            leading: Icon(FluentIcons.diet_plan_notebook),
            title: Text(getValidText(e.book.name, 5)),
            onPressed: () {
              print("objesssst");
            },
          ),
          ListTile(
            leading: Icon(FluentIcons.app_icon_default),
            title: Text(getValidText(e.category.name, 5)),
            trailing: InfoBadge(
              source: Text('${e.category.count}'),
            ),
            onPressed: () {
              print("objesssst");
            },
          ),
        ],
      ),
    );
  }

  static String snakeCasetoSentenceCase(String original) {
    return '${original[0].toUpperCase()}${original.substring(1)}'
        .replaceAll(RegExp(r'(_|-)+'), ' ');
  }

  Widget getHoverIcon(BuildContext context) {
    return IconButton(
        icon: Icon(FluentIcons.cancel),
        onPressed: () async {
          await showDialog(
              context: context,
              builder: (context) {
                return ContentDialog(
                  title: const Text('Confirm remove'),
                  content:
                      const Text('Are you sure you want to remove this card?'),
                  actions: [
                    FilledButton(
                      child: const Text('Yes'),
                      onPressed: () {
                        //TODO do some remove
                        Navigator.pop(context);
                      },
                    ),
                    Button(
                      child: const Text('No'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              });
        });
  }

  Widget getHoverButton(Content content, BuildContext context) {
    return Row(children: [
      FilledButton(
          child: Text("edit"),
          onPressed: () async {
            await Dialog.editContent(content, context);
            print("edit");
          }),
      SizedBox(
        width: 10.0,
      ),
      Button(
        child: Text('detail'),
        onPressed: () async {
          await Dialog.showContent(content, context);
          print("dasf");
        },
      )
    ]);
  }

  BoxDecoration getBoxDecration(
    BuildContext context,
    Set<ButtonStates> state,
  ) {
    final theme = context.watch<AppTheme>();
    switch (theme.mode) {
      case ThemeMode.system:
      case ThemeMode.light:
        if (state.isHovering) {
          return kOnBoxHover;
        } else {
          return kOnBoxNormal;
        }
      case ThemeMode.dark:
        if (state.isHovering) {
          return kOnDarkBoxHover;
        } else {
          return kOnDarkBoxNormal;
        }
    }
  }
}
