import 'package:fluent_ui/fluent_ui.dart';

import '../dialogs.dart';
import 'card_page.dart';

class Category {
  String name;
  int count;
  Category(this.name, this.count);
}

final _mockList = [
  Category("操作系统", 10),
  Category("计算机网络", 11),
  Category("最短路径", 12),
  Category("最短路径", 13),
];

class CategoryPage extends StatefulWidget {
  CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('Your Categories'),
      ),
      bottomBar: const SizedBox(
        width: double.infinity,
        child: InfoBar(
          title: Text('Tip:'),
          content: Text(
            'You can click on any icon to copy its name to the clipboard!',
          ),
        ),
      ),
      content: GridView.builder(
        padding: EdgeInsetsDirectional.only(
          start: PageHeader.horizontalPadding(context),
          end: PageHeader.horizontalPadding(context),
        ),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
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
                child: Tooltip(
                  useMousePosition: false,
                  message:
                      '\nFluentIcons.${e.name}\n(tap to copy to clipboard)\n',
                  child: RepaintBoundary(
                    child: AnimatedContainer(
                      duration: FluentTheme.of(context).slowAnimationDuration,
                      decoration: BoxDecoration(
                        color: ButtonThemeData.uncheckedInputColor(
                          FluentTheme.of(context),
                          states,
                          transparentWhenNone: true,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InfoBadge(
                                source: Text('${e.count}'),
                              )
                            ],
                          ),
                          const Icon(FluentIcons.app_icon_default, size: 40),
                          Padding(
                            padding: const EdgeInsetsDirectional.only(top: 8.0),
                            child: Text(
                              snakeCasetoSentenceCase(e.name),
                              style: TextStyle(fontSize: 15.0),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          Expanded(child: Container()),
                          if (states.isHovering)
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                  icon: Icon(FluentIcons.add),
                                  onPressed: () async {
                                    await Dialog.editContent(
                                        Content.create()..category.name = "hey",
                                        context,
                                        fixedCate: true);
                                  }),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String snakeCasetoSentenceCase(String original) {
    return '${original[0].toUpperCase()}${original.substring(1)}'
        .replaceAll(RegExp(r'(_|-)+'), ' ');
  }
}
