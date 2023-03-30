import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:note_app/common_widget.dart';
import 'package:note_app/models/dto.dart';
import 'package:note_app/theme.dart';
import 'package:note_app/util/font_util.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/link.dart';

import '../dialogs.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final categoryTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Your Categories'),
        commandBar: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Link(
            uri: Uri.parse('https://space.bilibili.com/24264499'),
            builder: (context, open) => Tooltip(
              message: 'Bilibili channel',
              child: IconButton(
                icon: const Icon(FluentIcons.open_source, size: 24.0),
                onPressed: open,
              ),
            ),
          ),
        ]),
      ),
      content: appData.category.isEmpty
          ? Center(
              child: Text(
                '还没有任何分类',
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
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              itemCount: appData.category.length,
              itemBuilder: (context, index) {
                final e = appData.category.elementAt(index);
                return HoverButton(
                  onPressed: () async {
                    appData.setContentWithCate(e);
                    final state = context.read<AppState>();
                    state.state = MyState.kOnContents;
                    context.goNamed("noteapp",
                        queryParams: {"dest": "card", "filter": "category"});
                  },
                  cursor: SystemMouseCursors.copy,
                  builder: (context, states) {
                    return FocusBorder(
                      focused: states.isFocused,
                      renderOutside: false,
                      child: RepaintBoundary(
                        child: AnimatedContainer(
                          duration:
                              FluentTheme.of(context).slowAnimationDuration,
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
                              if (states.isHovering)
                                Align(
                                  alignment: Alignment.topRight,
                                  child: getHoverIcon(
                                    e,
                                    context,
                                    call: () async {
                                      await appData.deleteCategory(e);
                                    },
                                  ),
                                ),
                              if (states.isHovering)
                                const SizedBox(
                                  height: 8.0,
                                ),
                              if (!states.isHovering)
                                const SizedBox(
                                  height: 20.0,
                                ),
                              if (!states.isHovering)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InfoBadge(
                                      source: Text('${e.count}'),
                                    )
                                  ],
                                ),
                              const Icon(FluentIcons.app_icon_default,
                                  size: 40),
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(top: 8.0),
                                child: Text(
                                  e.name,
                                  style: getFontStyle(size: 15.0),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                              Expanded(child: Container()),
                              if (states.isHovering)
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                          icon: const Icon(
                                              FluentIcons.edit_mirrored),
                                          onPressed: () async {
                                            await showTextDialog(context,
                                                title:
                                                    const Text('Edit category'),
                                                content: TextBox(
                                                  controller:
                                                      categoryTextController,
                                                ), call: () async {
                                              final name =
                                                  categoryTextController.text;
                                              categoryTextController.clear();
                                              final check =
                                                  await Category.getByName(
                                                      name);
                                              if (name.isEmpty ||
                                                  check != null) {
                                                // ignore: use_build_context_synchronously
                                                await showInfoBar(context,
                                                    title: Text(
                                                      '分类为空或已存在',
                                                      style: getFontStyle(
                                                          size: 15.0),
                                                    ),
                                                    severity:
                                                        InfoBarSeverity.error);
                                              } else {
                                                e.name = name;
                                                appData.addCategory(e);
                                              }
                                            });
                                          }),
                                      const SizedBox(
                                        width: 5.0,
                                      ),
                                      IconButton(
                                          icon: const Icon(FluentIcons.add),
                                          onPressed: () async {
                                            await Dialog.editContent(
                                                Content()..category = e,
                                                context,
                                                fixedCate: true);
                                          }),
                                    ])
                            ],
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
}
