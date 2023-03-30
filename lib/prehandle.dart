import 'package:isar/isar.dart';
import 'package:ffi/ffi.dart';
import 'dart:ffi' as ffi;
import 'package:note_app/main.dart';
import 'package:note_app/models/dto.dart';
import 'package:note_app/models/model.dart';
import 'package:note_app/util/ffi-gen.dart';

updateStatus(StatusModel statusModel) {
  isar.writeTxnSync(() {
    isar.statusModels.putSync(statusModel);
  });
}

finalHandle() {
  final v = isar.statusModels.where().findFirstSync();
  if (v == null) {
    updateStatus(StatusModel()
      ..status = currentPid
      ..lastTimestamp = DateTime.now().microsecondsSinceEpoch);
    return;
  }
  v.lastTimestamp = v.latestTimstamp;
  updateStatus(v);
}

Future<bool> preHandle() async {
  isar = await isarFuture;
  final v = isar.statusModels.where().findFirstSync();
  if (v == null) {
    currentPid = MyLibrary.getPid();
    updateStatus(StatusModel()
      ..status = currentPid
      ..latestTimstamp = DateTime.now().microsecondsSinceEpoch);
    return true;
  }
  final nativeUtf8 = title.toNativeUtf8().cast<ffi.Int8>();
  if (MyLibrary.existPidWithTitle(v.status, nativeUtf8)) {
    calloc.free(nativeUtf8);
    currentPid = v.status;
    return false;
  }

  currentPid = v.status = MyLibrary.getPid();
  v.latestTimstamp = DateTime.now().microsecondsSinceEpoch;
  updateStatus(v);
  calloc.free(nativeUtf8);
  return true;
}
