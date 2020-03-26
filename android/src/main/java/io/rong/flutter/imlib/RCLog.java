package io.rong.flutter.imlib;

import android.util.Log;

public class RCLog {
    private static String TAG = "[RC-Flutter-IM] Android ";
    public static void i(String msg) {
        Log.i(TAG,msg);
    }

    public static void e(String msg) {
        Log.e(TAG+"error ",msg);
    }
}
