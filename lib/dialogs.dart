import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mt;
import 'package:markdown_editable_textinput/markdown_text_input.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:note_app/screens/book_page.dart';
import 'package:note_app/screens/card_page.dart';
import 'package:note_app/screens/category_page.dart';
import 'package:note_app/theme.dart';
import 'package:note_app/util/code-wrapper.dart';
import 'package:note_app/util/font_util.dart';
import 'package:note_app/util/latex.dart';
import 'package:provider/provider.dart';

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

final _mockList = ["a", "b", "c"];

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
  static final _categoryController = TextEditingController();
  static final _detailController = TextEditingController();

  static Widget _mainPage(Content? content, BuildContext context,
      {bool fixedBook = false, bool fixedCate = false}) {
    if (content != null) {
      _titleController.value = TextEditingValue(text: content.title);
      _categoryController.value = TextEditingValue(text: content.category.name);
      _categoryController.value = TextEditingValue(text: content.detail ?? "");
    }
    final appData = context.watch<AppData>();
    _detailController.addListener(() {
      appData.markdownTxt = _detailController.text;
    });

    final isDark = FluentTheme.of(context).brightness.isDark;
    final config =
        isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig;
    return mt.Scaffold(
        body: ListView(
      children: [
        subtitle(content: const Text("Fill in title(must)")),
        Card(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4.0)),
          child: TextBox(
            style: getFontStyle(size: 20.0, fontWeight: FontWeight.w500),
            controller: _titleController,
            maxLines: null,
          ),
        ),
        subtitle(content: const Text("Fill in bookmark(must)")),
        Card(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4.0)),
          child: AutoSuggestBox<String>(
              placeholder: _getBookmark(content),
              enabled: !fixedBook,
              style: getFontStyle(size: 14.0, fontWeight: FontWeight.w500),
              controller: _categoryController,
              items: _mockList
                  .map<AutoSuggestBoxItem<String>>((e) => AutoSuggestBoxItem(
                      label: e,
                      value: e,
                      onFocusChange: (focused) {
                        if (focused) print("focus $e");
                      }))
                  .toList()),
        ),
        subtitle(content: const Text("Fill in category(must)")),
        Card(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4.0)),
          child: AutoSuggestBox<String>(
              placeholder: _getCategory(content),
              enabled: !fixedCate,
              style: getFontStyle(size: 14.0, fontWeight: FontWeight.w500),
              controller: _categoryController,
              items: _mockList
                  .map<AutoSuggestBoxItem<String>>((e) => AutoSuggestBoxItem(
                      label: e,
                      value: e,
                      onFocusChange: (focused) {
                        if (focused) print("focus $e");
                      }))
                  .toList()),
        ),
        subtitle(content: const Text("Fill in detail(optional)")),
        Expander(
            headerShape: (open) => const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
            header: const Text('detail text'),
            content: Column(
              children: [
                mt.Padding(
                    padding: EdgeInsets.fromLTRB(2.0, 10.0, 15.0, 2.0),
                    child: MarkdownTextInput(
                      (value) => appData.markdownTxt = value,
                      "",
                      textStyle:
                          getFontStyle(size: 18, fontWeight: FontWeight.normal),
                    )),
                const Divider(
                  direction: Axis.vertical,
                  size: 2.0,
                ),
                MarkdownWidget(
                    shrinkWrap: true,
                    data: appData.markdownTxt,
                    config: config,
                    markdownGeneratorConfig: MarkdownGeneratorConfig(
                      generators: [latexGenerator],
                      inlineSyntaxList: [LatexSyntax()],
                    ))
              ],
            )),
      ],
    ));
  }

  static Future<Content?> _newContent(
      {Content? content,
      required BuildContext context,
      bool fixedBook = false,
      bool fixedCate = false}) async {
    var ret = Content("", Category("", 0), Book(""));
    bool status = true;
    if (content == null) _titleController.clear();
    await showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: Row(
              children: [
                Text('Edit Card'),
                Expanded(child: Container()),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      icon: Icon(FluentIcons.cancel),
                      onPressed: () {
                        Navigator.pop(context);
                        status = false;
                      }),
                ),
              ],
            ),
            constraints: BoxConstraints(
                maxHeight: 800.0,
                maxWidth: 700.0,
                minHeight: 550,
                minWidth: 550),
            content: _mainPage(content, context,
                fixedBook: fixedBook, fixedCate: fixedCate),
            actions: [
              FilledButton(
                child: const Text('Yes'),
                onPressed: () {
                  ret.title = _titleController.text;
                  ret.category.name = _categoryController.text;
                  ret.detail = _detailController.text;
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

  static editContent(Content content, BuildContext context,
      {bool fixedBook = false, bool fixedCate = false}) async {
    final ret = await _newContent(
        content: content,
        context: context,
        fixedBook: fixedBook,
        fixedCate: fixedCate);
    if (ret == null) return;
    await displayInfoBar(context, builder: (context, close) {
      return InfoBar(
        title: const Text('You edit:'),
        content: Text(
            '{title:${ret.title},category:${ret.category},detail:${ret.detail}}'),
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
        severity: InfoBarSeverity.info,
      );
    });
  }

  static showContent(Content content, BuildContext context) async {
    final text = '''
```
书本：${content.book.name}

分类：${content.category.name}

标题：${content.title}
```
${content.detail ?? ""}''';
    final isDark = FluentTheme.of(context).brightness.isDark;
    final config =
        isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig;

    await showDialog(
        context: context,
        builder: (ctx) {
          return ContentDialog(
              constraints: BoxConstraints(
                  maxHeight: 800.0,
                  maxWidth: 700.0,
                  minHeight: 550,
                  minWidth: 550),
              title: Row(
                children: [
                  Expanded(child: Container()),
                  IconButton(
                      icon: Icon(FluentIcons.cancel),
                      onPressed: () {
                        Navigator.pop(ctx);
                      }),
                ],
              ),
              content: Column(
                children: [
                  MarkdownWidget(
                      shrinkWrap: true,
                      data: text,
                      config: config,
                      markdownGeneratorConfig: MarkdownGeneratorConfig(
                        generators: [latexGenerator],
                        inlineSyntaxList: [LatexSyntax()],
                      ))
                ],
              ));
        });
  }
}
