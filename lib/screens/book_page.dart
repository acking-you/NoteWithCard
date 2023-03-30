import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:note_app/common_widget.dart';
import 'package:note_app/dialogs.dart';
import 'package:note_app/models/dto.dart';
import 'package:note_app/theme.dart';
import 'package:note_app/util/font_util.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/link.dart';

void showCopiedSnackbar(BuildContext context, String copiedText) {
  showSnackbar(
    context,
    Snackbar(
      content: RichText(
        text: TextSpan(
          text: 'Copied ',
          style: const TextStyle(color: Colors.white),
          children: [
            TextSpan(
              text: copiedText,
              style: TextStyle(
                color: Colors.blue.defaultBrushFor(
                  FluentTheme.of(context).brightness,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      extended: true,
    ),
  );
}

class BookPage extends StatefulWidget {
  const BookPage({Key? key}) : super(key: key);

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  var filterText = "";
  final bookTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Your Bookmarks'),
        commandBar: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Link(
            uri: Uri.parse('https://github.com/ACking-you/NoteWithCard'),
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
      content: appData.books.isEmpty
          ? Center(
              child: Text(
                '还没有任何书本',
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
              itemCount: appData.books.length,
              itemBuilder: (context, index) {
                final e = appData.books.elementAt(index);
                return HoverButton(
                  onPressed: () async {
                    appData.setContentWithBook(e);
                    final state = context.read<AppState>();
                    state.state = MyState.kOnContents;
                    context.goNamed("noteapp",
                        queryParams: {"dest": "card", "filter": "book"});
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
                                      await appData.deleteBook(e);
                                    },
                                  ),
                                ),
                              Padding(
                                padding: states.isHovering
                                    ? const EdgeInsets.only(top: 5.0)
                                    : const EdgeInsets.only(top: 34.0),
                                child:
                                    const Icon(FluentIcons.articles, size: 40),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(top: 8.0),
                                child: Text(
                                  getValidText(e.name, 10),
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
                                                title: const Text('Edit book'),
                                                content: TextBox(
                                                  controller:
                                                      bookTextController,
                                                ), call: () async {
                                              final name =
                                                  bookTextController.text;
                                              bookTextController.clear();
                                              final check =
                                                  await Book.getByName(name);
                                              if (name.isEmpty ||
                                                  check != null) {
                                                // ignore: use_build_context_synchronously
                                                await showInfoBar(context,
                                                    title: Text(
                                                      '名字为空或已存在',
                                                      style: getFontStyle(
                                                          size: 15.0),
                                                    ),
                                                    severity:
                                                        InfoBarSeverity.error);
                                              } else {
                                                e.name = name;
                                                appData.addBook(e);
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
                                                Content()..book = e, context,
                                                fixedBook: true);
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
