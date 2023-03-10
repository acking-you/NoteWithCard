import 'package:clipboard/clipboard.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:note_app/dialogs.dart';
import 'package:note_app/screens/card_page.dart';
import 'package:note_app/util/font_util.dart';

class Book {
  String name;
  Book(this.name);
}

final _mockList = [Book("math"), Book("语文"), Book("计算机网络"), Book("计算机操作系统")];
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
  BookPage({Key? key}) : super(key: key);

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  var filterText = "";
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('Your Bookmarks'),
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
              await FlutterClipboard.copy(copyText);
              showCopiedSnackbar(context, copyText);
            },
            cursor: SystemMouseCursors.copy,
            builder: (context, states) {
              return FocusBorder(
                focused: states.isFocused,
                renderOutside: false,
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
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: const Icon(FluentIcons.articles, size: 40),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(top: 8.0),
                          child: Text(
                            getValidText(e.name, 10),
                            style: getFontStyle(size: 15.0),
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
                                      Content.create()..book.name = "hey",
                                      context,
                                      fixedBook: true);
                                }),
                          )
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
