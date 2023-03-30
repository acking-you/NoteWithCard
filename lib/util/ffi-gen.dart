// ignore: file_names
import 'dart:ffi' as ffi;

typedef GetPidFunc = int Function(); // 定义一个函数类型
typedef ExistPidFunc = bool Function(int);
typedef ExistPidWithTitleFunc = bool Function(int, ffi.Pointer<ffi.Int8>);
typedef ShowWindowFunc = int Function(int, ffi.Pointer<ffi.Int8>);
typedef exist_pid_func = ffi.Bool Function(ffi.Int);
typedef exist_pid_with_title_func = ffi.Bool Function(
    ffi.Int, ffi.Pointer<ffi.Int8>);
typedef getpid_func = ffi.Int Function();
typedef show_window_func = ffi.Int Function(ffi.Int, ffi.Pointer<ffi.Int8>);

class MyLibrary {
  static final ffi.DynamicLibrary nativeLib =
      ffi.DynamicLibrary.open("windowsapp_singleton.dll"); // Windows 上的动态链接库文件名

  static final GetPidFunc getPid =
      nativeLib.lookup<ffi.NativeFunction<getpid_func>>('getpid').asFunction();
  static final ExistPidFunc existPid = nativeLib
      .lookup<ffi.NativeFunction<exist_pid_func>>('exist_pid')
      .asFunction();
  static final ShowWindowFunc showWindow = nativeLib
      .lookup<ffi.NativeFunction<show_window_func>>('show_window')
      .asFunction();
  static final ExistPidWithTitleFunc existPidWithTitle = nativeLib
      .lookup<ffi.NativeFunction<exist_pid_with_title_func>>(
          'exist_pid_with_title')
      .asFunction();
}
