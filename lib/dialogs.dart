import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mt;
import 'package:flutter/services.dart';
import 'package:flutter_prism/flutter_prism.dart';
import 'package:isar/isar.dart';
import 'package:markdown_toolbar/markdown_toolbar.dart';
import 'package:markdown_viewer/markdown_viewer.dart';
import 'package:note_app/common_widget.dart';
import 'package:note_app/log.dart';
import 'package:note_app/models/dto.dart';
import 'package:note_app/theme.dart';
import 'package:note_app/util/font_util.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

Widget description({required Widget content}) {
  return Builder(builder: (context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 4.0),
      child: DefaultTextStyle(
        style: FluentTheme.of(context).typography.body!,
        child: content,
      ),
    );
  });
}

Widget subtitle({required Widget content}) {
  return Builder(builder: (context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 14.0, bottom: 2.0),
      child: DefaultTextStyle(
        style: FluentTheme.of(context).typography.subtitle!,
        child: content,
      ),
    );
  });
}

String _getBookmark(Content? content) {
  if (content == null) return "";
  return content.book.name;
}

String _getCategory(Content? content) {
  if (content == null) return "";
  return content.category.name;
}

class Dialog {
  static final _titleController = TextEditingController();
  static final _bookContorller = TextEditingController();
  static final _categoryController = TextEditingController();
  static final _markdownController = TextEditingController();
  static final _markdownFocusNode = FocusNode();
  static final textScrollController = ScrollController();
  static final scrollController = ScrollController();

  static bool isListenMarkdown = false;

  static Widget _mainPage(Content? content, BuildContext context,
      {bool fixedBook = false, bool fixedCate = false}) {
    if (content != null) {
      _titleController.value = TextEditingValue(text: content.title);
      _bookContorller.value = TextEditingValue(text: content.book.name);
      _categoryController.value = TextEditingValue(text: content.category.name);
      _markdownController.value = TextEditingValue(text: content.detail ?? "");
    }
    final appData = context.read<AppData>();
    final commonData = context.read<CommonData>();
    if (!isListenMarkdown) {
      _markdownController.addListener(() {
        commonData.setMarkdownTxt(_markdownController.text);
      });
    }

    return mt.Scaffold(
        body: SingleChildScrollView(
            controller: scrollController,
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Column(
                children: [
                  Expander(
                      initiallyExpanded: true,
                      header: const Text('Must info'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          subtitle(content: const Text("title(must)")),
                          Card(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4.0)),
                            child: TextBox(
                              style: getFontStyle(
                                  size: 20.0, fontWeight: FontWeight.w500),
                              controller: _titleController,
                              maxLines: null,
                            ),
                          ),
                          subtitle(content: const Text("bookmark(must)")),
                          Card(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4.0)),
                            child: AutoSuggestBox<Book>(
                                placeholder: _getBookmark(content),
                                enabled: !fixedBook,
                                style: getFontStyle(
                                    size: 14.0, fontWeight: FontWeight.w500),
                                controller: _bookContorller,
                                items: appData.books
                                    .map<AutoSuggestBoxItem<Book>>(
                                        (e) => AutoSuggestBoxItem(
                                            label: e.name,
                                            value: e,
                                            onFocusChange: (focused) {
                                              if (focused) print("focus $e");
                                            }))
                                    .toList()),
                          ),
                          subtitle(content: const Text("category(must)")),
                          Card(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4.0)),
                            child: AutoSuggestBox<Category>(
                                placeholder: _getCategory(content),
                                enabled: !fixedCate,
                                style: getFontStyle(
                                    size: 14.0, fontWeight: FontWeight.w500),
                                controller: _categoryController,
                                items: appData.category
                                    .map<AutoSuggestBoxItem<Category>>((e) =>
                                        AutoSuggestBoxItem(
                                            label: e.name, value: e))
                                    .toList()),
                          ),
                        ],
                      )),
                  Expander(
                      headerShape: (open) => const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                      header: const Text('Optional info'),
                      content: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: mt.Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    2.0, 10.0, 15.0, 2.0),
                                child: Column(
                                  children: [
                                    MarkdownToolbar(
                                      width: 45.0,
                                      height: 32.0,
                                      useIncludedTextField: false,
                                      controller: _markdownController,
                                      focusNode: _markdownFocusNode,
                                    ),
                                    const mt.Divider(),
                                    RawKeyboardListener(
                                      focusNode: FocusNode(),
                                      onKey: (RawKeyEvent event) {
                                        if (event.logicalKey ==
                                            LogicalKeyboardKey.tab) {
                                          // 插入tab字符到文本框中
                                          final TextEditingValue value =
                                              _markdownController.value;
                                          final int start =
                                              value.selection.baseOffset;
                                          final int end =
                                              value.selection.extentOffset;
                                          final TextEditingValue text =
                                              TextEditingValue(
                                            text:
                                                '${value.text.substring(0, start)}\t\t${value.text.substring(end)}',
                                            selection: TextSelection.collapsed(
                                                offset: start + 1),
                                          );
                                          _markdownController.value = text;
                                        }
                                      },
                                      child: mt.TextField(
                                        scrollController: textScrollController,
                                        controller: _markdownController,
                                        focusNode: _markdownFocusNode,
                                        textInputAction:
                                            TextInputAction.newline,
                                        minLines: 5,
                                        maxLines: null,
                                        style: getFontStyle(size: 18.0),
                                        decoration: mt.InputDecoration(
                                            hintText: '输入...',
                                            hintStyle: getFontStyle(
                                              size: 18.0,
                                            ),
                                            labelText: 'detail text',
                                            border:
                                                const mt.OutlineInputBorder(),
                                            enabledBorder:
                                                const mt.OutlineInputBorder()),
                                      ),
                                    )
                                  ],
                                )),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  2.0, 10.0, 15.0, 2.0),
                              child: Column(
                                children: [
                                  Text(
                                    'MarkDown Preview',
                                    style: getFontStyle(size: 25.0),
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  Consumer(
                                    builder:
                                        (context, CommonData value, child) {
                                      return MyMarkdownView(
                                        text: value.markdownTxt,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            )));
  }

  static Future<Content?> _newContent(
      {Content? content,
      required BuildContext context,
      bool fixedBook = false,
      bool fixedCate = false}) async {
    Content ret = content ?? Content();
    bool status = true;
    if (content == null) _titleController.clear();
    await showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: Stack(
              children: [
                DragToMoveArea(
                  child: Row(
                    children: const [
                      Text('Edit Card'),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      icon: const Icon(FluentIcons.cancel),
                      onPressed: () {
                        Navigator.pop(context);
                        status = false;
                      }),
                ),
              ],
            ),
            constraints: const BoxConstraints(
              maxHeight: 1280.0,
              maxWidth: 1920.0,
            ),
            content: _mainPage(content, context,
                fixedBook: fixedBook, fixedCate: fixedCate),
            actions: [
              FilledButton(
                child: const Text('Yes'),
                onPressed: () async {
                  final commonData = context.read<CommonData>();
                  ret.title = _titleController.text;
                  if (_titleController.text.isEmpty) {
                    await showCheckFieldError(context, '标题未填写');
                    return;
                  }
                  if (!fixedBook) {
                    if (_bookContorller.text.isEmpty) {
                      await showCheckFieldError(context, '书本名未填写');
                      return;
                    }
                    ret.book.name = _bookContorller.text;
                  }
                  if (!fixedCate) {
                    if (_categoryController.text.isEmpty) {
                      // ignore: use_build_context_synchronously
                      await showCheckFieldError(context, '分类未填写');
                      return;
                    }
                    ret.category.name = _categoryController.text;
                  }
                  ret.detail = commonData.markdownTxt;
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  status = true;
                },
              ),
              Button(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                  status = false;
                },
              ),
            ],
          );
        });
    return status ? ret : null;
  }

  static showCheckFieldError(BuildContext context, String errorInfo) async {
    await displayInfoBar(context, builder: (context, close) {
      return InfoBar(
        title: const Text('未填写字段:'),
        content: Text(errorInfo),
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
        severity: InfoBarSeverity.error,
      );
    });
  }

  static editContent(Content content, BuildContext context,
      {bool fixedBook = false,
      bool fixedCate = false,
      bool onlyEdit = false}) async {
    Content? old;

    if (onlyEdit) {
      old = content.clone();
    }

    final ret = await _newContent(
        content: content,
        context: context,
        fixedBook: fixedBook,
        fixedCate: fixedCate);
    if (ret == null) return;

    // ignore: use_build_context_synchronously
    final appData = Provider.of<AppData>(context, listen: false);
    int id;
    bool needPlus = true;
    if (onlyEdit) {
      needPlus = false;
      if (old!.book.name != ret.book.name) {
        final n = await Book.getByName(ret.book.name);
        ret.book.id = n == null ? Isar.autoIncrement : n.id;
      }
      if (old.category.name != ret.category.name) {
        final n = await Category.getByName(ret.category.name);
        //把修改前的分类对应的数量-1
        old.category.count -= 1;
        old.category.id = ret.category.id;
        id = await appData.addCategory(old.category);
        //修改后的对应的分类需要+1
        needPlus = true;
        if (n == null) {
          ret.category.id = Isar.autoIncrement;
          ret.category.count = 0;
        } else {
          ret.category.id = n.id;
          ret.category.count = n.count;
        }
      }
    }
    id = await appData.addContent(ret, needPlus: needPlus);
    // ignore: use_build_context_synchronously
    await displayInfoBar(context, builder: (context, close) {
      return InfoBar(
        title: const Text('结果:'),
        content: Text(id == content.id ? '成功编辑内容' : '成功创建内容'),
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
        severity: InfoBarSeverity.info,
      );
    });
  }

  static Widget getComboBoxWidget(
      {required String keyName,
      required String title,
      required void Function(String?) call,
      required VoidCallback addCall}) {
    return Row(
      children: [
        Text(
          title,
          style: getFontStyle(size: 17.0),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Consumer2(builder: (context, AppData value, CommonData value2, child) {
          final list = value.getValuesByKey(keyName);
          return list == null
              ? Button(
                  onPressed: null,
                  child: Text(
                    'please add a path',
                    style: getFontStyle(size: 16.0),
                  ))
              : ComboBox<String>(
                  value:
                      keyName == 'work' ? value2.workPath : value2.editorPath,
                  items: list
                      .map((e) => ComboBoxItem(
                            value: e,
                            child: Text(
                              e,
                              style: getFontStyle(size: 16.0),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    logger.d(v);
                    call(v);
                  },
                );
        }),
        const Expanded(child: SizedBox()),
        Button(onPressed: addCall, child: const Text('Add Path'))
      ],
    );
  }

  static showContent(Content content, BuildContext context) async {
    final text = '''
```
书本：${content.book.name}

分类：${content.category.name}

标题：${content.title}
```
${content.detail ?? ""}''';
    await showDialog(
        context: context,
        builder: (ctx) {
          return ContentDialog(
            constraints: const BoxConstraints(
              maxHeight: 1080,
              maxWidth: 1920,
            ),
            title: Stack(
              children: [
                DragToMoveArea(
                  child: Row(
                    children: [
                      Text(
                        content.title,
                        style: getFontStyle(size: 25.0),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
                Builder(builder: (context) {
                  return Positioned(
                    right: 45.0,
                    child: Tooltip(
                      message: 'save as markdown file',
                      child: IconButton(
                          icon: const Icon(FluentIcons.download_document),
                          onPressed: () async {
                            final ret = await FilePicker.platform.saveFile(
                                fileName: '${content.title}.md',
                                type: FileType.custom,
                                allowedExtensions: ['md']);
                            if (ret != null) {
                              logger.d(ret);
                              final file = File(ret);
                              await file.writeAsString(text, flush: true);
                              // ignore: use_build_context_synchronously
                              await showInfoBar(context,
                                  title: Text(
                                    '提示:',
                                    style: getFontStyle(size: 14.0),
                                  ),
                                  content: Text(
                                    '导出文件成功',
                                    style: getFontStyle(size: 14.0),
                                  ));
                            }
                          }),
                    ),
                  );
                }),
                Positioned(
                  right: 5.0,
                  child: IconButton(
                      icon: const Icon(FluentIcons.cancel),
                      onPressed: () {
                        Navigator.pop(ctx);
                      }),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Expander(
                      header: const Text('open md by other editor'),
                      content: Column(
                        children: [
                          Card(
                            child: getComboBoxWidget(
                                keyName: 'work',
                                title: 'Working Path:',
                                call: (v) {
                                  if (v == null) return;
                                  final data = context.read<CommonData>();
                                  data.setWorkPath(v);
                                },
                                addCall: () async {
                                  final path = await getDirctoryPath();
                                  if (path == null) return;
                                  // ignore: use_build_context_synchronously
                                  final data = context.read<AppData>();
                                  await data.addKeyValue('work', path);
                                  data.loadValues();
                                }),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Card(
                            child: getComboBoxWidget(
                                keyName: 'editor',
                                title: 'Editor Path:    ',
                                call: (v) {
                                  if (v == null) return;
                                  final data = context.read<CommonData>();
                                  data.setEditorPath(v);
                                },
                                addCall: () async {
                                  final paths = await getFilePaths();
                                  if (paths == null) return;
                                  // ignore: use_build_context_synchronously
                                  final data = context.read<AppData>();
                                  for (final path in paths) {
                                    if (path == null) continue;
                                    await data.addKeyValue('editor', path);
                                  }
                                  data.loadValues();
                                }),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Builder(builder: (context) {
                            return FilledButton(
                              child: const Text('open'),
                              onPressed: () async {
                                final data = context.read<CommonData>();
                                if (data.workPath.isEmpty) {
                                  await showInfoBar(context,
                                      title: const Text('Work path is empty!'),
                                      severity: InfoBarSeverity.error);
                                  return;
                                }
                                if (data.editorPath.isEmpty) {
                                  await showInfoBar(context,
                                      title:
                                          const Text('Editor path is empty!'),
                                      severity: InfoBarSeverity.error);
                                  return;
                                }
                                final savePath =
                                    '${data.workPath}/${content.title}.md';
                                final file = File(savePath);
                                await file.writeAsString(text, flush: true);
                                // ignore: use_build_context_synchronously
                                await showInfoBar(context,
                                    title: Text(
                                      'tip:',
                                      style: getFontStyle(size: 16.0),
                                    ),
                                    content: Text(
                                      'Save file successful!',
                                      style: getFontStyle(size: 18.0),
                                    ));
                                final process = await Process.start(
                                    data.editorPath, [savePath]);
                                process.stdout
                                    .transform(utf8.decoder)
                                    .listen((event) {
                                  logger.d('stdout:$event');
                                });
                                process.stderr
                                    .transform(utf8.decoder)
                                    .listen((event) {
                                  logger.d('stderr:$event');
                                });
                                final code = await process.exitCode;
                                logger.d('exit_code:$code');
                              },
                            );
                          }),
                        ],
                      )),
                  Expander(
                    initiallyExpanded: true,
                    header: const Text('markdown view'),
                    content: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: MyMarkdownView(
                        text: text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class MyMarkdownView extends StatelessWidget {
  final _langSet = {
    "c",
    "cpp",
    "cmake",
    "java",
    "cs",
    "go",
    "rust",
    "js",
    "ts",
    "dart",
    "swift",
    "kotlin",
    "nim",
    "v",
    "basic",
    "shell",
    "sh",
    "powershell",
    "sql",
    "py",
    "r",
    "python",
    "scala",
    "julia",
    "php",
    "html",
    "css",
    "json",
    "xml",
    "md",
    "rb",
    "vim",
    "bash",
    "erlang",
    "ini",
    "lua",
    "yaml",
    "yml",
    "toml",
    "docker",
  };

  final String text;
  final double? codeSize;
  final double? textSize;
  MyMarkdownView({super.key, required this.text, this.codeSize, this.textSize});

  @override
  Widget build(BuildContext context) {
    return MarkdownViewer(
      text,
      enableTaskList: true,
      enableSuperscript: false,
      enableSubscript: false,
      enableFootnote: false,
      enableImageSize: false,
      enableKbd: false,
      highlightBuilder: (text, language, infoString) {
        if (!_langSet.contains(language)) {
          language = 'plain';
        }
        final prism = Prism(
          mouseCursor: SystemMouseCursors.text,
          style: FluentTheme.of(context).brightness == Brightness.dark
              ? const PrismStyle.dark()
              : const PrismStyle(),
        );
        return prism.render(text, language ?? 'plain');
      },
      onTapLink: (href, title) async {
        if (href == null) return;
        logger.d(href, title);
        await launchUrl(Uri.parse(href));
      },
      styleSheet: MarkdownStyle(
          listItemMarkerTrailingSpace: 8,
          codeSpan: getCodeFontStyle(size: codeSize ?? 16.0),
          codeBlock: getCodeFontStyle(size: codeSize ?? 16.0),
          textStyle: getFontStyle(size: textSize ?? 18.0)),
    );
  }
}
