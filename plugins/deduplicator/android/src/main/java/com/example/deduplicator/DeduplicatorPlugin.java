package com.example.deduplicator;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.security.DigestInputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

interface DuplicatesCallback {
    void onComplete(ArrayList<ArrayList<String>> duplicates);
}

/**
 * DeduplicatorPlugin
 */
public class DeduplicatorPlugin implements FlutterPlugin, MethodCallHandler,
        EventChannel.StreamHandler {
    private static final String TAG = "deduplicatorPlugin";
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel methodChannel;
    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;

    private Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();

        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "deduplicator/method");
        methodChannel.setMethodCallHandler(this);

        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "deduplicator/event");
        eventChannel.setStreamHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + Build.VERSION.RELEASE);
                break;
            case "getDuplicateFiles":
                getDuplicateFiles(getAllFiles(context));
                break;
            case "getDuplicateFilesF":
                getDuplicatesOnBackground(
                        new DuplicatesCallback() {
                            @Override
                            public void onComplete(ArrayList<ArrayList<String>> duplicates) {
                                result.success(duplicates);
                            }
                        }
                );
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
    }

    public void getDuplicatesOnBackground(
            final DuplicatesCallback callback
    ) {
        Executor executor = Executors.newSingleThreadExecutor();
        executor.execute(new Runnable() {
            @Override
            public void run() {

                ArrayList<ArrayList<String>> duplicates = getDuplicateFiles(getAllFiles(context));
                callback.onComplete(duplicates);
            }
        });
    }

    public List<File> getAllFiles(Context context) {
        Log.e(TAG, "Getting All Files");
        try {
            List<File> files = new ArrayList<>();

/*
      String pdf = MimeTypeMap.getSingleton().getMimeTypeFromExtension("pdf");
      */
/*String doc = MimeTypeMap.getSingleton().getMimeTypeFromExtension("doc");
      String docx = MimeTypeMap.getSingleton().getMimeTypeFromExtension("docx");
      String xlsx = MimeTypeMap.getSingleton().getMimeTypeFromExtension("xlsx");
      String txt = MimeTypeMap.getSingleton().getMimeTypeFromExtension("txt");
      String ppt = MimeTypeMap.getSingleton().getMimeTypeFromExtension("ppt");
      String pptx = MimeTypeMap.getSingleton().getMimeTypeFromExtension("pptx");
*/

      /*String mp4 = MimeTypeMap.getSingleton().getMimeTypeFromExtension("mp4");
      String mkv = MimeTypeMap.getSingleton().getMimeTypeFromExtension("mkv");
      String avi = MimeTypeMap.getSingleton().getMimeTypeFromExtension("avi");

      String apk = MimeTypeMap.getSingleton().getMimeTypeFromExtension("apk");
      String mp3 = MimeTypeMap.getSingleton().getMimeTypeFromExtension("mp3");
*/
            //Uri table = MediaStore.Files.getContentUri("external");
            Uri table = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;

            String[] data = new String[]{MediaStore.Images.ImageColumns.DATA};
            /*String where = *//*MediaStore.Files.FileColumns.MIME_TYPE + "=?" + " OR "
              + MediaStore.Files.FileColumns.MIME_TYPE + "=?" + " OR "
              + MediaStore.Files.FileColumns.MIME_TYPE + "=?" + " OR "
              + MediaStore.Files.FileColumns.MIME_TYPE + "=?" + " OR "
              + MediaStore.Files.FileColumns.MIME_TYPE + "=?" + " OR "
              + MediaStore.Files.FileColumns.MIME_TYPE + "=?" + " OR "
              + MediaStore.Files.FileColumns.MIME_TYPE + "=?" + " OR "
              + MediaStore.Files.FileColumns.MIME_TYPE + "=?" + " OR "
              + MediaStore.Files.FileColumns.MIME_TYPE + "=?" + " OR "
              + MediaStore.Files.FileColumns.MIME_TYPE + "=?" + " OR "
              + MediaStore.Files.FileColumns.MIME_TYPE + "=?" + " OR "
              + */
            /*    String[] args = new String[]{pdf, *//*doc, docx, xlsx, txt, ppt, pptx, *//*png, jpg, jpeg, gif, *//*mp4, mkv, avi, apk, mp3*//*};
             */
            String sortOrder = MediaStore.Images.Media.DATE_TAKEN + " DESC, " + MediaStore.Images.Media.DATE_MODIFIED + " DESC";

            Cursor imageCursor;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {

                Bundle queryArgs = new Bundle();
                queryArgs.putStringArray(
                        android.content.ContentResolver.QUERY_ARG_SORT_COLUMNS,
                        new String[]
                                {
                                        MediaStore.Images.Media.DATE_TAKEN,
                                        MediaStore.Images.Media.DATE_MODIFIED
                                }
                );
                queryArgs.putInt(
                        android.content.ContentResolver.QUERY_ARG_SORT_DIRECTION,

                        android.content.ContentResolver.QUERY_SORT_DIRECTION_DESCENDING

                );
                imageCursor = context.getContentResolver().query(
                        table,
                        data,
                        queryArgs,
                        null
                );
            } else {
                imageCursor = context.getContentResolver().query(table, data, null, null, sortOrder);
            }

            if (imageCursor != null) {
                Log.e(TAG, "Getting All Files: Image Cursor != null");
                while (imageCursor.moveToNext()) {
                    File file = new File(imageCursor.getString(imageCursor.getColumnIndexOrThrow(data[0])));
                    files.add(file);
                }
                imageCursor.close();
            }
            Log.e(TAG, "All Files Length = " + files.size());
            return files;
        } catch (Exception e) {
            Log.e(TAG, e.toString());
            Log.e(TAG, "All Files Length = zero");
            return new ArrayList<>();
        }
    }

    public ArrayList<ArrayList<String>> getDuplicateFiles(List<File> files) {
        HashMap<String, ArrayList<String>> hashmap = new HashMap<>();
        HashMap<String, ArrayList<String>> duplicateHashSetOld = new HashMap<>();
        HashMap<String, ArrayList<String>> duplicateHashSetNew = new HashMap<>();
        ArrayList<ArrayList<String>> duplicateList = null;

        for (File file : files) {
            //Log.e(TAG, "This File Path = " + file.getAbsolutePath());
            String md5 = getFileMD5ToString(file);
            if (hashmap.containsKey(md5)) {
                ArrayList<String> original = hashmap.get(md5);
                assert original != null;
                Log.e(TAG, "Duplicate Found = " + file.getAbsolutePath() + "\n"
                        + original.get(0));
                if (duplicateHashSetNew.containsKey(md5)) {
                    List<String> fileList;
                    if (original != null) {
                        fileList = original;
                        fileList.add(original.get(0));
                    } else {
                        fileList = new ArrayList<>();
                        fileList.add(file.getAbsolutePath());
                    }
                } else {
                    ArrayList<String> fileList = new ArrayList<>();
                    if (original == null) {
                        original = new ArrayList<>();
                    }

                    fileList.add(original.get(0));
                    fileList.add(file.getAbsolutePath());
                    duplicateHashSetNew.put(md5, fileList);
                }
            } else {
                ArrayList<String> fileList = new ArrayList<>();
                fileList.add(file.getAbsolutePath());
                hashmap.put(md5, fileList);
                //Log.e(TAG, "Hashmap Files = " + hashmap.toString());
            }
        }

        duplicateList = new ArrayList<ArrayList<String>>(duplicateHashSetNew.values());

        //if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
        if (eventSink != null) {
            Log.e(TAG, "Sending Duplicate Files");
              /*if (duplicateHashSetOld != duplicateHashSetNew) {
                Log.e(TAG, "Duplicate Hash set new != Duplicate Hash set old");*/
            //duplicateHashSetOld = duplicateHashSetNew;
            //Log.e(TAG, "Duplicate Files : " + duplicateList.toString());
            eventSink.success(duplicateList);
            //}
        }//}

        if (duplicateList != null) {
            //Log.e(TAG, "getDuplicateFiles: " + duplicateList.toString());
        }
        return duplicateList;
    }

    public static String getFileMD5ToString(final File file) {
        return bytes2HexString(getFileMD5(file), true);
    }

    private static final char[] HEX_DIGITS_UPPER =
            {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
    private static final char[] HEX_DIGITS_LOWER =
            {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};

    public static String bytes2HexString(final byte[] bytes, boolean isUpperCase) {
        if (bytes == null) return "";
        char[] hexDigits = isUpperCase ? HEX_DIGITS_UPPER : HEX_DIGITS_LOWER;
        int len = bytes.length;
        if (len <= 0) return "";
        char[] ret = new char[len << 1];
        for (int i = 0, j = 0; i < len; i++) {
            ret[j++] = hexDigits[bytes[i] >> 4 & 0x0f];
            ret[j++] = hexDigits[bytes[i] & 0x0f];
        }
        return new String(ret);
    }

    public static byte[] getFileMD5(final File file) {
        if (file == null) return null;
        DigestInputStream dis = null;
        try {
            FileInputStream fis = new FileInputStream(file);
            MessageDigest md = MessageDigest.getInstance("MD5");
            dis = new DigestInputStream(fis, md);
            byte[] buffer = new byte[1024 * 256];
            while (true) {
                if (!(dis.read(buffer) > 0)) break;
            }
            md = dis.getMessageDigest();
            return md.digest();
        } catch (NoSuchAlgorithmException | IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (dis != null) {
                    dis.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        eventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        eventSink = null;
    }
}