package com.example.deduplicator;

import static android.app.Activity.RESULT_OK;

import android.annotation.SuppressLint;
import android.app.PendingIntent;
import android.app.RecoverableSecurityException;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;

import androidx.activity.ComponentActivity;
import androidx.annotation.NonNull;
import androidx.room.Room;

import com.example.deduplicator.data.daos.DuplicateImagesDao;
import com.example.deduplicator.data.daos.ImageDao;
import com.example.deduplicator.data.db.AppDatabase;
import com.example.deduplicator.data.models.DuplicateImages;
import com.example.deduplicator.data.models.Image;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.security.DigestInputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

interface DuplicatesCallback {
    void onComplete(ArrayList<ArrayList<String>> duplicates);
}

interface DeleteCallback {
    void onComplete();
}

/**
 * DeduplicatorPlugin
 */
public class DeduplicatorPlugin implements FlutterPlugin, MethodCallHandler,
        EventChannel.StreamHandler , ActivityAware, PluginRegistry.ActivityResultListener {
    private static final String TAG = "deduplicatorPlugin";
    private static final int DELETE_FILES_REQUEST_CODE = 5635;
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel methodChannel;
    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;

    private Context context;
    private ComponentActivity activity;

    private ImageDao imageDao;
    private DuplicateImagesDao duplicateImagesDao;

    private ArrayList<Uri> urisToDelete;
    private Result deleteResult;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();

        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "deduplicator/method");
        methodChannel.setMethodCallHandler(this);

        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "deduplicator/event");
        eventChannel.setStreamHandler(this);

        AppDatabase db = Room.databaseBuilder(context,
                AppDatabase.class, "deduplicate_database").build();
        imageDao = db.imageDao();
        duplicateImagesDao = db.duplicateImagesDao();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + Build.VERSION.RELEASE);
                break;
            case "getDuplicateFiles":
                getDuplicatePicsPaths(getPicturesFiles(context));
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
            case "deleteFiles": {
                ArrayList<String> paths = call.arguments();
                if(paths != null && !paths.isEmpty()) {
                    deleteResult = result;
                    urisToDelete = new ArrayList<>();
                    for(String path : paths) {
                        urisToDelete.add(getUriFromPath(context, new File(path)));
                    }
                    delete();
                }
                break;
            }
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
                ArrayList<ArrayList<String>> duplicates = getDuplicatePicsPaths(getPicturesFiles(context));
                callback.onComplete(duplicates);
            }
        });
    }

    public List<File> getPicturesFiles(Context context) {
        Log.e(TAG, "Getting All Files");
        try {
            List<File> files = new ArrayList<>();

            Uri table = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;

            String[] data = new String[]{MediaStore.Images.ImageColumns.DATA};

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

/*    public ArrayList<ArrayList<String>> getDuplicatePicsPaths(List<File> files) {
        HashMap<String, ArrayList<String>> allPicturesHashmap = new HashMap<>();
        HashMap<String, ArrayList<String>> duplicatesHashMap = new HashMap<>();
        ArrayList<ArrayList<String>> duplicatesList = null;

        for (File file : files) {
            String md5 = getFileMD5ToString(file);
            if (allPicturesHashmap.containsKey(md5)) {
                ArrayList<String> original = allPicturesHashmap.get(md5);
                assert original != null;
                Log.e(TAG, "Duplicate Found = " + file.getAbsolutePath() + "\n"
                        + original);
                if (duplicatesHashMap.containsKey(md5)) {
                    ArrayList<String> fileList;
                    if (original != null) {
                        fileList = original;
                        //fileList.addAll(original);
                        fileList.add(file.getAbsolutePath());
                    } else {
                        fileList = new ArrayList<>();
                        fileList.add(file.getAbsolutePath());
                    }
                    duplicatesHashMap.put(md5, fileList);
                    allPicturesHashmap.put(md5, fileList);
                } else {
                    if (original == null) {
                        original = new ArrayList<>();
                    }

                    ArrayList<String> fileList = new ArrayList<>(original);
                    fileList.add(file.getAbsolutePath());
                    duplicatesHashMap.put(md5, fileList);
                    allPicturesHashmap.put(md5, fileList);
                }
            } else {
                ArrayList<String> fileList = new ArrayList<>();
                fileList.add(file.getAbsolutePath());
                allPicturesHashmap.put(md5, fileList);
            }
        }

        duplicatesList = new ArrayList<ArrayList<String>>(duplicatesHashMap.values());

        if (eventSink != null) {
            Log.e(TAG, "Sending Duplicate Files");

            eventSink.success(duplicatesList);
        }
        return duplicatesList;
    }
    */

    public ArrayList<ArrayList<String>> getDuplicatePicsPaths(List<File> files) {

        HashSet<String> allHashs = new HashSet<>();

        ArrayList<ArrayList<String>> duplicatesList = new ArrayList<>();

        for (File file : files) {
            String md5 = getFileMD5ToString(file);
            imageDao.insertAll(new Image(file.getAbsolutePath(),
                    md5));
            allHashs.add(md5);
        }

        for (String hash : allHashs) {
            List<Image> duplicates = imageDao.findDuplicate(hash);
            if(duplicates.size() > 1) {
                DuplicateImages duplicateImages = new DuplicateImages(hash, new ArrayList<String>());

                ArrayList<String> paths = new ArrayList<>();

                for (Image image : duplicates) {
                    duplicateImages.addImage(image);
                    paths.add(image.path);
                }
                duplicateImagesDao.insertAll(duplicateImages);
                duplicatesList.add(paths);
            }
        }

        if (eventSink != null) {
            Log.e(TAG, "Sending Duplicate Files");

            eventSink.success(duplicatesList);
        }
        return duplicatesList;
    }

    public static String getFileMD5ToString(final File file) {
        return bytes2HexString(getFileMD5(file), true);
    }

    public static String bytes2HexString(final byte[] bytes, boolean isUpperCase) {
        if (bytes == null) return "";
        char[] hexDigitsUpper = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
        int len = bytes.length;
        if (len <= 0) return "";
        char[] ret = new char[len << 1];
        for (int i = 0, j = 0; i < len; i++) {
            ret[j++] = hexDigitsUpper[bytes[i] >> 4 & 0x0f];
            ret[j++] = hexDigitsUpper[bytes[i] & 0x0f];
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

    public void delete() {
        try {
            deleteOnBackground();
        } catch (SecurityException e) {

            PendingIntent pendingIntent = null;

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {

                pendingIntent = MediaStore.createDeleteRequest(context.getContentResolver(), urisToDelete);

            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {

                //if exception is recoverable then again send delete request using intent
                if (e instanceof RecoverableSecurityException) {
                    RecoverableSecurityException exception = (RecoverableSecurityException) e;
                    pendingIntent = exception.getUserAction().getActionIntent();
                }
            } else {
                deleteResult.success(false);
                return;
            }

            if (pendingIntent != null) {
                try {
                    pendingIntent.send(DELETE_FILES_REQUEST_CODE);
                } catch (PendingIntent.CanceledException canceledException) {
                    canceledException.printStackTrace();
                }
            }
        }
    }

    public void deleteOnBackground() {
        final DeleteCallback callback = new DeleteCallback() {
            @Override
            public void onComplete() {
                deleteResult.success(true);
            }
        };
        Executor executor = Executors.newSingleThreadExecutor();
        executor.execute(new Runnable() {
            @Override
            public void run() {
                for(Uri uri : urisToDelete) {
                    //delete object using resolver
                    context.getContentResolver().delete(uri, null, null);
                }
                callback.onComplete();
            }
        });
    }

    public static Uri getUriFromPath(Context context, File file) {
        String filePath = file.getAbsolutePath();
        Cursor cursor = context.getContentResolver().query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                new String[]{MediaStore.Images.Media._ID},
                MediaStore.Images.Media.DATA + "=? ",
                new String[]{filePath}, null);
        if (cursor != null && cursor.moveToFirst()) {
            @SuppressLint("Range") int id = cursor.getInt(cursor.getColumnIndex(MediaStore.MediaColumns._ID));
            cursor.close();
            return Uri.withAppendedPath(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "" + id);
        } else {
            if (file.exists()) {
                ContentValues values = new ContentValues();
                values.put(MediaStore.Images.Media.DATA, filePath);
                return context.getContentResolver().insert(
                        MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
            } else {
                return null;
            }
        }
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        eventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        eventSink = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = (ComponentActivity) binding.getActivity();
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activity = (ComponentActivity) binding.getActivity();
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivity() {
    activity = null;
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == DELETE_FILES_REQUEST_CODE){
            if (resultCode == RESULT_OK) {
                if (Build.VERSION.SDK_INT == Build.VERSION_CODES.Q) {
                    deleteOnBackground();
                }
            } else {
                deleteResult.success(false);
            }
            return true;
        }
        return false;
    }
}