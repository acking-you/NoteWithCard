import 'package:isar/isar.dart';
import 'package:note_app/log.dart';
import 'package:note_app/models/model.dart';
import 'package:crimson/crimson.dart';
part 'dto.g.dart';

final isarFuture = Isar.open([
  BookModelSchema,
  CategoryModelSchema,
  ContentModelSchema,
  KVModelSchema,
  StatusModelSchema
]);

late Isar isar;

@json
class Category {
  @jsonIgnore
  Id id = Isar.autoIncrement;
  String name = "";
  int count = 0;

  static Future<List<Category>> allCategory() async {
    final List<Category> category = [];
    final ret = await isar.categoryModels.where().findAll();
    for (final v in ret) {
      category.add(Category()
        ..id = v.id
        ..name = v.name
        ..count = v.count);
    }
    return category;
  }

  static Future<CategoryModel?> get(int id) async {
    assert(id != Isar.autoIncrement);
    return await isar.categoryModels.get(id);
  }

  static Future<bool> delete(int id) async {
    return await isar.writeTxn(() async {
      return await isar.categoryModels.delete(id);
    });
  }

  static Future<CategoryModel?> getByName(String name) async {
    return await isar.categoryModels.where().nameEqualTo(name).findFirst();
  }

  static Future<int> newCategory(Category category) async {
    return isar.writeTxn(() async {
      return await isar.categoryModels.put(CategoryModel()
        ..name = category.name
        ..id = category.id
        ..count = category.count);
    });
  }

  static Future<List<Content>> allContents(Category category) async {
    assert(category.id != Isar.autoIncrement);

    final List<Content> contents = [];
    final ret = await isar.contentModels
        .filter()
        .categoryIdEqualTo(category.id)
        .findAll();
    for (final v in ret) {
      final book = await Book.get(v.bookId);
      final category = await get(v.categoryId);
      final con = Content()
        ..id = v.id
        ..title = v.title
        ..detail = v.detail
        ..book.id = v.bookId
        ..category.id = v.categoryId
        ..book.name = book!.name
        ..category.name = category!.name
        ..category.count = category.count;

      contents.add(con);
    }
    return contents;
  }
}

@json
class Content {
  @jsonIgnore
  Id id = Isar.autoIncrement;
  String title = "";
  Category category = Category();
  Book book = Book();
  String? detail;

  @override
  String toString() {
    return 'id:$id title:$title category:${category.name} book:${book.name}';
  }

  Content clone() {
    final ret = Content();
    ret.book = Book();
    ret.category = Category();
    ret.title = title;
    ret.detail = detail;
    ret.id = id;
    ret.book.name = book.name;
    ret.category.name = category.name;
    ret.category.count = category.count;
    return ret;
  }

  static Future<bool> delete(int id) async {
    return await isar.writeTxn(() async {
      return await isar.contentModels.delete(id);
    });
  }

  static Future<int> deleteByCategoryId(int id) async {
    return await isar.writeTxn(() async {
      return await isar.contentModels
          .filter()
          .categoryIdEqualTo(id)
          .deleteAll();
    });
  }

  static Future<int> deleteByBookId(int id) async {
    final list = await isar.contentModels.filter().bookIdEqualTo(id).findAll();
    for (final v in list) {
      final cate = await Category.get(v.categoryId);
      if (cate != null && cate.count > 0) {
        cate.count--;
        Category.newCategory(Category()
          ..id = cate.id
          ..name = cate.name
          ..count = cate.count);
      }
    }
    final ret = await isar.writeTxn(() async {
      return await isar.contentModels.filter().bookIdEqualTo(id).deleteAll();
    });

    return ret;
  }

  static Future<int> newContent(Content content, {needPlus = true}) async {
    //check if exsit
    if (content.book.id == Isar.autoIncrement) {
      final b = await Book.getByName(content.book.name);
      if (b != null) {
        content.book.id = b.id;
      }
    }
    if (content.category.id == Isar.autoIncrement) {
      final b = await Category.getByName(content.category.name);
      if (b != null) {
        content.category.id = b.id;
        content.category.count = b.count;
      }
    }
    if (needPlus) content.category.count++;

    //add book or category
    final bid = await Book.newBook(content.book);
    final cid = await Category.newCategory(content.category);
    final id = await isar.writeTxn(() async {
      return await isar.contentModels.put(ContentModel()
        ..id = content.id
        ..bookId = bid
        ..categoryId = cid
        ..title = content.title
        ..detail = content.detail);
    });

    return id;
  }

  static Future<List<Content>> allContent() async {
    final List<Content> contents = [];
    final ret = await isar.contentModels.where().findAll();
    for (final v in ret) {
      final book = await Book.get(v.bookId);
      final category = await Category.get(v.categoryId);
      final content = Content()
        ..id = v.id
        ..title = v.title
        ..book.id = v.bookId
        ..category.id = v.categoryId
        ..book.name = book!.name
        ..category.name = category!.name
        ..category.count = category.count
        ..detail = v.detail;
      contents.add(content);
    }
    logger.d('len:${contents.length} $contents');
    return contents;
  }

  static Future<List<Content>> titleStartWith(String pattern) async {
    final searchContents = <Content>[];
    final ret = await allContent();
    for (final v in ret) {
      if (!v.title.startsWith(pattern)) {
        continue;
      }
      searchContents.add(v);
      if (searchContents.length > 10) {
        break;
      }
    }

    logger.d('len:${searchContents.length} $searchContents');

    return searchContents;
  }
}

@json
class Book {
  @jsonIgnore
  Id id = Isar.autoIncrement;
  String name = "";

  static Future<List<Book>> allBooks() async {
    final List<Book> books = [];
    final ret = await isar.bookModels.where().findAll();
    for (final v in ret) {
      books.add(Book()
        ..id = v.id
        ..name = v.name);
    }
    return books;
  }

  static Future<BookModel?> get(int id) async {
    assert(id != Isar.autoIncrement);
    final ret = await isar.bookModels.get(id);
    return ret;
  }

  static Future<bool> delete(int id) async {
    return await isar.writeTxn(() async {
      return isar.bookModels.delete(id);
    });
  }

  static Future<BookModel?> getByName(String name) async {
    final ret = await isar.bookModels.where().nameEqualTo(name).findFirst();
    return ret;
  }

  static Future<List<Content>> allContents(Book book) async {
    assert(book.id != Isar.autoIncrement);

    final List<Content> contents = [];
    final ret =
        await isar.contentModels.filter().bookIdEqualTo(book.id).findAll();
    for (final v in ret) {
      final book = await Book.get(v.bookId);
      final category = await Category.get(v.categoryId);

      contents.add(Content()
        ..id = v.id
        ..title = v.title
        ..detail = v.detail
        ..book.id = v.bookId
        ..category.id = v.categoryId
        ..book.name = book!.name
        ..category.name = category!.name
        ..category.count = category.count);
    }
    return contents;
  }

  static Future<int> newBook(Book book) async {
    return await isar.writeTxn(() async {
      return isar.bookModels.put(BookModel()
        ..name = book.name
        ..id = book.id);
    });
  }
}
