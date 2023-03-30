import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mt;
import 'package:go_router/go_router.dart';
import 'package:note_app/dialogs.dart';
import 'package:note_app/log.dart';
import 'package:note_app/models/dto.dart';
import 'package:note_app/theme.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/link.dart';

import '../util/font_util.dart';

final kOnBoxHover = BoxDecoration(
    // border: Border.all(color: Colors.grey[30]),
    color: const Color.fromARGB(255, 249, 249, 248),
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: [
      BoxShadow(
        color: mt.Colors.grey.shade400,
        blurRadius: 20,
      ),
    ]);

final kOnBoxNormal = BoxDecoration(
    color: const Color.fromARGB(255, 249, 249, 249),
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

// ignore: must_be_immutable
class CardPage extends StatefulWidget {
  CardPage({
    Key? key,
    this.filter,
  }) : super(key: key);
  String? filter;
  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
        header: PageHeader(
          title: const Text('Your Cards'),
          commandBar: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Link(
              uri: Uri.parse('https://acking-you.github.io'),
              builder: (context, open) => Tooltip(
                message: 'About author',
                child: IconButton(
                  icon: const Icon(FluentIcons.open_source, size: 24.0),
                  onPressed: open,
                ),
              ),
            ),
          ]),
        ),
        content: Consumer(
          builder: (context, AppData value, child) {
            late List<Content> v;
            switch (widget.filter) {
              case "title":
                v = value.getContentsWithTitle();
                break;
              case "book":
                v = value.getContentsWithBook();
                break;
              case "category":
                v = value.getContentsWithCate();
                break;
              default:
                v = value.allContents;
            }
            logger.d(
                'allContents:\nlen:${value.allContents.length}, ${v.toList()}');
            logger.d('getContentWithTitle:\nlen:${v.length}, ${v.toList()}');
            return v.isEmpty
                ? Center(
                    child: Text(
                      '还没有任何卡片',
                      style: getFontStyle(
                        size: 20.0,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsetsDirectional.only(
                      start: PageHeader.horizontalPadding(context),
                      end: PageHeader.horizontalPadding(context),
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 250,
                      mainAxisSpacing: 15.0,
                      crossAxisSpacing: 22.0,
                    ),
                    itemCount: v.length,
                    itemBuilder: (context, index) {
                      final e = v.elementAt(index);
                      return HoverButton(
                          onPressed: () {},
                          cursor: SystemMouseCursors.copy,
                          builder: (context, states) {
                            return FocusBorder(
                              focused: states.isFocused,
                              renderOutside: false,
                              child: RepaintBoundary(
                                child: Stack(children: [
                                  AnimatedContainer(
                                      duration: FluentTheme.of(context)
                                          .slowAnimationDuration,
                                      height: 250,
                                      width: 250,
                                      decoration:
                                          getBoxDecration(context, states)),
                                  Center(
                                    child: getCenterContent(context, e),
                                  ),
                                  if (states.isHovering)
                                    Positioned(
                                        right: 15.0,
                                        bottom: 10.0,
                                        child: getHoverButton(e, context)),
                                  if (states.isHovering)
                                    Positioned(
                                        top: 1,
                                        right: 1,
                                        child: getHoverIcon(e, context)),
                                ]),
                              ),
                            );
                          });
                    },
                  );
          },
        ));
  }

  Widget getCenterContent(BuildContext context, Content e) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            leading: const Icon(FluentIcons.title),
            title: Text(
              getValidText(e.title, 6),
              style: getFontStyle(size: 17.0),
            ),
          ),
          ListTile(
            leading: const Icon(FluentIcons.diet_plan_notebook),
            title: Text(
              getValidText(e.book.name, 5),
              style: getFontStyle(size: 14.0),
            ),
            onPressed: () async {
              final appData = context.read<AppData>();
              await appData.setContentWithBook(e.book);
              // ignore: use_build_context_synchronously
              context.goNamed("noteapp",
                  queryParams: {"dest": "card", "filter": "book"});
            },
          ),
          ListTile(
            leading: const Icon(FluentIcons.app_icon_default),
            title: Text(getValidText(e.category.name, 5)),
            trailing: InfoBadge(
              source: Text(
                '${e.category.count}',
                style: getFontStyle(size: 14.0),
              ),
            ),
            onPressed: () async {
              final appData = context.read<AppData>();
              await appData.setContentWithCate(e.category);
              // ignore: use_build_context_synchronously
              context.goNamed("noteapp",
                  queryParams: {"dest": "card", "filter": "category"});
            },
          ),
        ],
      ),
    );
  }

  Widget getHoverIcon(Content content, BuildContext context) {
    final appData = context.read<AppData>();
    return IconButton(
        icon: const Icon(FluentIcons.cancel),
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
                      onPressed: () async {
                        await appData.deleteContent(content);
                        // ignore: use_build_context_synchronously
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
          child: const Text("edit"),
          onPressed: () async {
            await Dialog.editContent(content, context, onlyEdit: true);
          }),
      const SizedBox(
        width: 10.0,
      ),
      Button(
        child: const Text('detail'),
        onPressed: () async {
          await Dialog.showContent(content, context);
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
