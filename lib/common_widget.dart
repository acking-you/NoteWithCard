import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:note_app/models/dto.dart';
import 'package:note_app/theme.dart';
import 'package:provider/provider.dart';

Future<void> showInfoBar(BuildContext context,
    {required Widget title,
    Widget? content,
    InfoBarSeverity severity = InfoBarSeverity.info}) async {
  return await displayInfoBar(context, builder: (context, close) {
    return InfoBar(
      title: title,
      content: content,
      action: IconButton(
        icon: const Icon(FluentIcons.clear),
        onPressed: close,
      ),
      severity: severity,
    );
  });
}

void contentBase64Encode(List<Content?> content) {
  for (final c in content) {
    if (c != null && c.detail != null) {
      c.detail = base64.encode(utf8.encode(c.detail!));
    }
  }
}

void contentBase64Decode(List<Content?> content) {
  for (final c in content) {
    if (c != null && c.detail != null) {
      c.detail = utf8.decode(base64.decode(c.detail!));
    }
  }
}

Future<String?> getDirctoryPath() async {
  return await FilePicker.platform
      .getDirectoryPath(dialogTitle: 'select working directory');
}

Future<List<String?>?> getFilePaths() async {
  final ret = await FilePicker.platform
      .pickFiles(allowMultiple: true, dialogTitle: 'select file to executable');
  if (ret == null) {
    return null;
  } else {
    return ret.files.map((e) => e.path).toList();
  }
}

showTextDialog(BuildContext context,
    {Text? title,
    Widget? content,
    required VoidCallback call,
    VoidCallback? noCall}) async {
  await showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: title,
          content: content,
          actions: [
            FilledButton(
              child: const Text('Yes'),
              onPressed: () {
                call();
                Navigator.pop(context);
              },
            ),
            Button(
              child: const Text('No'),
              onPressed: () {
                if (noCall != null) noCall();
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
}

Widget getHoverIcon<T>(T content, BuildContext context,
    {required VoidCallback call}) {
  final appData = context.read<AppData>();
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
                      call();
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
