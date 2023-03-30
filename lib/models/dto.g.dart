// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto.dart';

// **************************************************************************
// CrimsonGenerator
// **************************************************************************

extension ReadCategory on Crimson {
  Category readCategory() {
    late String name;
    late int count;

    loop:
    while (true) {
      switch (iterObjectHash()) {
        case -1:
          break loop;
        case -4270347329889690746: // name
          name = readString();
          break;
        case -5627843058667511180: // count
          count = readInt();
          break;
        default:
          skip();
          break;
      }
    }

    final obj = Category();
    obj.name = name;
    obj.count = count;
    return obj;
  }

  List<Category> readCategoryList() {
    final list = <Category>[];
    while (iterArray()) {
      list.add(readCategory());
    }
    return list;
  }

  List<Category?> readCategoryOrNullList() {
    final list = <Category?>[];
    while (iterArray()) {
      list.add(skipNull() ? null : readCategory());
    }
    return list;
  }
}

extension WriteCategory on CrimsonWriter {
  void writeCategory(Category value) {
    writeObjectStart();
    writeObjectKeyRaw('name');
    final nameVal = value.name;
    writeString(nameVal);
    writeObjectKeyRaw('count');
    final countVal = value.count;
    writeNum(countVal);
    writeObjectEnd();
  }

  void writeCategoryList(List<Category> list) {
    writeArrayStart();
    for (final value in list) {
      writeCategory(value);
    }
    writeArrayEnd();
  }

  void writeCategoryOrNullList(List<Category?> list) {
    writeArrayStart();
    for (final value in list) {
      if (value == null) {
        writeNull();
      } else {
        writeCategory(value);
      }
    }
    writeArrayEnd();
  }
}

extension ReadContent on Crimson {
  Content readContent() {
    late String title;
    late Category category;
    late Book book;
    String? detail;

    loop:
    while (true) {
      switch (iterObjectHash()) {
        case -1:
          break loop;
        case -2724350755546111959: // title
          title = readString();
          break;
        case 6616605887935172241: // category
          category = readCategory();
          break;
        case -3661481903091873576: // book
          book = readBook();
          break;
        case -6293979897783841292: // detail
          detail = readStringOrNull();
          break;
        default:
          skip();
          break;
      }
    }

    final obj = Content();
    obj.title = title;
    obj.category = category;
    obj.book = book;
    obj.detail = detail;
    return obj;
  }

  List<Content> readContentList() {
    final list = <Content>[];
    while (iterArray()) {
      list.add(readContent());
    }
    return list;
  }

  List<Content?> readContentOrNullList() {
    final list = <Content?>[];
    while (iterArray()) {
      list.add(skipNull() ? null : readContent());
    }
    return list;
  }
}

extension WriteContent on CrimsonWriter {
  void writeContent(Content value) {
    writeObjectStart();
    writeObjectKeyRaw('title');
    final titleVal = value.title;
    writeString(titleVal);
    writeObjectKeyRaw('category');
    final categoryVal = value.category;
    writeCategory(categoryVal);
    writeObjectKeyRaw('book');
    final bookVal = value.book;
    writeBook(bookVal);
    writeObjectKeyRaw('detail');
    final detailVal = value.detail;
    if (detailVal == null) {
      writeNull();
    } else {
      writeString(detailVal);
    }
    writeObjectEnd();
  }

  void writeContentList(List<Content> list) {
    writeArrayStart();
    for (final value in list) {
      writeContent(value);
    }
    writeArrayEnd();
  }

  void writeContentOrNullList(List<Content?> list) {
    writeArrayStart();
    for (final value in list) {
      if (value == null) {
        writeNull();
      } else {
        writeContent(value);
      }
    }
    writeArrayEnd();
  }
}

extension ReadBook on Crimson {
  Book readBook() {
    late String name;

    loop:
    while (true) {
      switch (iterObjectHash()) {
        case -1:
          break loop;
        case -4270347329889690746: // name
          name = readString();
          break;
        default:
          skip();
          break;
      }
    }

    final obj = Book();
    obj.name = name;
    return obj;
  }

  List<Book> readBookList() {
    final list = <Book>[];
    while (iterArray()) {
      list.add(readBook());
    }
    return list;
  }

  List<Book?> readBookOrNullList() {
    final list = <Book?>[];
    while (iterArray()) {
      list.add(skipNull() ? null : readBook());
    }
    return list;
  }
}

extension WriteBook on CrimsonWriter {
  void writeBook(Book value) {
    writeObjectStart();
    writeObjectKeyRaw('name');
    final nameVal = value.name;
    writeString(nameVal);
    writeObjectEnd();
  }

  void writeBookList(List<Book> list) {
    writeArrayStart();
    for (final value in list) {
      writeBook(value);
    }
    writeArrayEnd();
  }

  void writeBookOrNullList(List<Book?> list) {
    writeArrayStart();
    for (final value in list) {
      if (value == null) {
        writeNull();
      } else {
        writeBook(value);
      }
    }
    writeArrayEnd();
  }
}
