import 'dart:io';

import 'package:crimson/crimson.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:note_app/common_widget.dart';
import 'package:note_app/models/dto.dart';
import 'package:note_app/theme.dart';
import 'package:note_app/util/font_util.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/link.dart';

class SavePage extends StatefulWidget {
  const SavePage({Key? key}) : super(key: key);

  @override
  State<SavePage> createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
        header: PageHeader(
          title: const Text('To Import&Export'),
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
        content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: getImportAndExportButton()));
  }

  Widget getHoverButton(
      {required IconData icon,
      required VoidCallback onPressed,
      required String text,
      double? iconSize,
      double? fontSize,
      double? width,
      double? height}) {
    return HoverButton(
      onPressed: onPressed,
      cursor: SystemMouseCursors.copy,
      builder: (context, states) {
        return FocusBorder(
          focused: states.isFocused,
          renderOutside: false,
          child: RepaintBoundary(
            child: AnimatedContainer(
              width: width,
              height: height,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  Icon(
                    icon,
                    size: iconSize,
                    color: FluentTheme.of(context).brightness.isDark
                        ? Colors.white.withRed(495)
                        : Colors.grey[150],
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 8.0),
                    child: Text(
                      text,
                      style: TextStyle(fontSize: fontSize),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> getImportAndExportButton() {
    return [
      Builder(builder: (context) {
        return getHoverButton(
            icon: FluentIcons.download,
            iconSize: 160.0,
            width: 250.0,
            fontSize: 25.0,
            onPressed: () async {
              final res = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ["json"],
              );
              if (res != null) {
                final file = File(res.paths.first!);
                final crimson = Crimson(await file.readAsBytes());
                final contents = crimson.readContentOrNullList();
                contentBase64Decode(contents);
                int count = 0;
                for (final content in contents) {
                  if (content != null) {
                    final id = await Content.newContent(content);
                    if (id > 0) ++count;
                  }
                }
                final appData = context.read<AppData>();
                await appData.loadAsync();

                // ignore: use_build_context_synchronously
                await showInfoBar(context,
                    title: Text(
                      '提示:',
                      style: getFontStyle(size: 14.0),
                    ),
                    content: Text(
                      '成功导入$count条数据',
                      style: getFontStyle(size: 14.0),
                    ));
              }
            },
            text: 'Import');
      }),
      const SizedBox(
        width: 50.0,
      ),
      getHoverButton(
          icon: FluentIcons.upload,
          iconSize: 160.0,
          width: 250.0,
          fontSize: 25.0,
          onPressed: () async {
            final res = await FilePicker.platform.getDirectoryPath(
              dialogTitle: 'Please select an output dir:',
            );
            if (res != null) {
              final writer = CrimsonWriter();
              final contents = await Content.allContent();
              contentBase64Encode(contents);
              writer.writeContentOrNullList(contents);
              File('$res/note_with_cards.json')
                  .writeAsBytesSync(writer.toBytes(), flush: true);
              // ignore: use_build_context_synchronously
              await showInfoBar(context,
                  title: Text(
                    '提示:',
                    style: getFontStyle(size: 14.0),
                  ),
                  content: Text(
                    '成功导出${contents.length}条数据',
                    style: getFontStyle(size: 14.0),
                  ));
            }
          },
          text: 'Export'),
    ];
  }
}
