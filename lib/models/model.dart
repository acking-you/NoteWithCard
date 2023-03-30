import 'package:isar/isar.dart';

part 'model.g.dart';

@collection
class StatusModel {
  Id id = Isar.autoIncrement;
  int status = 0;
  int latestTimstamp = 0;
  int lastTimestamp = 0;
}

@collection
class KVModel {
  Id id = Isar.autoIncrement;
  late String key;
  late String value;
}

@collection
class BookModel {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment
  @Index(unique: true)
  late String name;
}

@collection
class CategoryModel {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  @Index(unique: true)
  late String name;
  late int count;
}

@collection
class ContentModel {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment
  late String title;
  late int bookId;
  late int categoryId;
  String? detail;
}
