package io.rong.flutter.imlib;

import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetFileDescriptor;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Environment;
import android.os.ParcelFileDescriptor;
import android.provider.MediaStore;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.channels.FileChannel;

import io.rong.common.LibStorageUtils;
import io.rong.common.RLog;

public class StorageUtils {
    private static final String TAG = "LibStorageUtils";

    public static class MediaType {
        public static final String IMAGE = "image";
        public static final String VIDEO = "video";
    }


    public static boolean isQMode(Context context) {
        return LibStorageUtils.isQMode(context);
    }

    public static boolean isBuildAndTargetForQ(Context context) {
        return LibStorageUtils.isBuildAndTargetForQ(context);
    }

    /**
     * @param context 上下文
     * @param file    文件
     */
    private static boolean copyVideoToPublicDir(Context context, File file) {
        if (file == null || !file.exists()) {
            RLog.e(TAG, "file is not exist");
            return false;
        }

        boolean result = true;
        if (!StorageUtils.isBuildAndTargetForQ(context)) {
            File dirFile = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES);
            if (dirFile != null && !dirFile.exists()) {
                boolean mkdirResult = dirFile.mkdirs();
                if (!mkdirResult) {
                    RLog.e(TAG, "mkdir fail,dir path is " + dirFile.getAbsolutePath());
                    return false;
                }
            }
            if (dirFile == null) {
                RLog.e(TAG, "dirFile is null");
                return false;
            }

            FileInputStream fis = null;
            FileOutputStream fos = null;
            try {
                String filePath = dirFile.getPath() + "/" + file.getName();
                fis = new FileInputStream(file);
                fos = new FileOutputStream(filePath);
                copy(fis, fos);
                File destFile = new File(filePath);
                updatePhotoMedia(destFile, context);
            } catch (FileNotFoundException e) {
                result = false;
                RLog.e(TAG, "copyVideoToPublicDir file not found", e);
            } finally {
                try {
                    if (fis != null) {
                        fis.close();
                    }
                } catch (IOException e) {
                    RLog.e(TAG, "copyVideoToPublicDir: ", e);
                }
                try {
                    if (fos != null) {
                        fos.close();
                    }
                } catch (IOException e) {
                    RLog.e(TAG, "copyVideoToPublicDir: ", e);
                }
            }
        } else {
            result = copyVideoToPublicDirForQ(context, file);
        }
        return result;
    }

    // 通知图库进行数据刷新
    public static void updatePhotoMedia(File file, Context context) {
        if (file != null && file.exists()) {
            Intent intent = new Intent();
            intent.setAction(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
            intent.setData(Uri.fromFile(file));
            context.sendBroadcast(intent);
        }
    }

    private static boolean copyVideoToPublicDirForQ(Context context, File file) {
        boolean result = true;
        String filePath = "";
        if (file.exists() && file.isFile() && context != null) {
            Uri uri = insertVideoIntoMediaStore(context, file);
            if (uri != null) {
                filePath = uri.getPath();
            }
            try {
                ParcelFileDescriptor w = context.getContentResolver().openFileDescriptor(uri, "w");
                writeToPublicDir(file, w);
            } catch (FileNotFoundException pE) {
                RLog.e(TAG, "copyVideoToPublicDir uri is not Found, uri is" + uri.toString());
                result = false;
            }
            File destFile = new File(filePath);
            updatePhotoMedia(destFile, context);
        } else {
            RLog.e(TAG, "file is not Found or context is null ");
            result = false;
        }
        return result;
    }

    private static boolean copyImageToPublicDir(Context pContext, File pFile) {
        boolean result = true;
        File file = pFile;
        if (file.exists() && file.isFile() && pContext != null) {
            if (!StorageUtils.isBuildAndTargetForQ(pContext)) {
                File dirFile = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES);
                if (dirFile != null && !dirFile.exists()) {
                    boolean mkdirResult = dirFile.mkdirs();
                    if (!mkdirResult) {
                        RLog.e(TAG, "mkdir fail,dir path is " + dirFile.getAbsolutePath());
                        return false;
                    }
                }
                if (dirFile == null) {
                    RLog.e(TAG, "dirFile is null");
                    return false;
                }

                FileInputStream fis = null;
                FileOutputStream fos = null;
                try {
                    String filePath = dirFile.getPath() + "/" + file.getName();
                    fis = new FileInputStream(file);
                    fos = new FileOutputStream(filePath);
                    copy(fis, fos);
                    File destFile = new File(filePath);
                    updatePhotoMedia(destFile, pContext);
                } catch (FileNotFoundException e) {
                    result = false;
                    RLog.e(TAG, "copyImageToPublicDir file not found", e);
                } finally {
                    try {
                        if (fis != null) {
                            fis.close();
                        }
                    } catch (IOException e) {
                        RLog.e(TAG, "copyImageToPublicDir: ", e);
                    }
                    try {
                        if (fos != null) {
                            fos.close();
                        }
                    } catch (IOException e) {
                        RLog.e(TAG, "copyImageToPublicDir: ", e);
                    }
                }
            } else {
                String imgMimeType = getImgMimeType(file);
                Uri uri = insertImageIntoMediaStore(pContext, file.getName(), imgMimeType);
                try {
                    ParcelFileDescriptor w = pContext.getContentResolver().openFileDescriptor(uri, "w");
                    writeToPublicDir(file, w);
                } catch (FileNotFoundException pE) {
                    result = false;
                    RLog.e(TAG, "copyImageToPublicDir uri is not Found, uri is" + uri.toString());
                }
            }
        } else {
            result = false;
            RLog.e(TAG, "file is not Found or context is null ");
        }
        return result;
    }

    public static Uri insertImageIntoMediaStore(Context context, String fileName, String mimeType) {
        ContentValues contentValues = new ContentValues();
        contentValues.put(MediaStore.Images.Media.DISPLAY_NAME, fileName);
        contentValues.put(MediaStore.Images.Media.DATE_TAKEN, System.currentTimeMillis());
        contentValues.put(MediaStore.Images.Media.MIME_TYPE, mimeType);
        Uri uri = context.getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues);
        return uri;
    }

    public static Uri insertVideoIntoMediaStore(Context context, File file) {
        ContentValues contentValues = new ContentValues();
        contentValues.put(MediaStore.Video.Media.DISPLAY_NAME, file.getName());
        contentValues.put(MediaStore.Video.Media.DATE_TAKEN, System.currentTimeMillis());
        contentValues.put(MediaStore.Video.Media.MIME_TYPE, "video/mp4");

        Uri uri = context.getContentResolver().insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, contentValues);
        return uri;
    }

    public static void writeToPublicDir(File pFile, ParcelFileDescriptor pParcelFileDescriptor) {
        FileInputStream fis = null;
        FileOutputStream fos = null;
        try {
            fis = new FileInputStream(pFile);
            fos = new FileOutputStream(pParcelFileDescriptor.getFileDescriptor());
            copy(fis, fos);
        } catch (FileNotFoundException pE) {
            RLog.e(TAG, "writeToPublicDir file is not found file path is " + pFile.getAbsolutePath());
        } finally {
            try {
                if (fis != null) {
                    fis.close();
                }
            } catch (IOException e) {
                RLog.e(TAG, "writeToPublicDir: ", e);
            }
            try {
                if (fos != null) {
                    fos.close();
                }
            } catch (IOException e) {
                RLog.e(TAG, "writeToPublicDir: ", e);
            }
        }
    }

    public static void read(ParcelFileDescriptor parcelFileDescriptor, File dst) throws IOException {
        FileInputStream istream = new FileInputStream(parcelFileDescriptor.getFileDescriptor());
        try {
            FileOutputStream ostream = new FileOutputStream(dst);
            try {
                copy(istream, ostream);
            } finally {
                ostream.close();
            }
        } finally {
            istream.close();
        }
    }

    public static void copy(FileInputStream ist, FileOutputStream ost) {
        if (ist == null || ost == null)
            return;
        FileChannel fileChannelInput = null;
        FileChannel fileChannelOutput = null;
        try {
            //得到fileInputStream的文件通道
            fileChannelInput = ist.getChannel();
            //得到fileOutputStream的文件通道
            fileChannelOutput = ost.getChannel();
            //将fileChannelInput通道的数据，写入到fileChannelOutput通道
            fileChannelInput.transferTo(0, fileChannelInput.size(), fileChannelOutput);
        } catch (IOException e) {
            RLog.e(TAG, "copy method error", e);
        } finally {
            try {
                ist.close();
                if (fileChannelInput != null)
                    fileChannelInput.close();
                ost.close();
                if (fileChannelOutput != null)
                    fileChannelOutput.close();
            } catch (IOException e) {
                RLog.e(TAG, "copy method error", e);
            }
        }
    }

    public static String getImgMimeType(File imgFile) {
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        BitmapFactory.decodeFile(imgFile.getPath(), options);
        return options.outMimeType;
    }

    /**
     * @param type MediaStore类型，0：Images，1：Video，2：Audio
     * @param id   通过扫描获取到的MediaStore."xxx".Media._ID
     * @return content uri
     */
    public Uri getContentUri(int type, String id) {
        Uri uri;
        switch (type) {
            case 0:
                uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI.buildUpon().appendPath(String.valueOf(id)).build();
                break;
            case 1:
                uri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI.buildUpon().appendPath(String.valueOf(id)).build();
                break;
            case 2:
                uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI.buildUpon().appendPath(String.valueOf(id)).build();
                break;
            default:
                uri = null;
        }
        return uri;
    }

    public InputStream getFileInputStreamWithUri(Context pContext, Uri pUri) {
        InputStream inputStream = null;
        ContentResolver cr = pContext.getContentResolver();
        try {
            AssetFileDescriptor r = cr.openAssetFileDescriptor(pUri, "r");
            ParcelFileDescriptor parcelFileDescriptor = r.getParcelFileDescriptor();
            if (parcelFileDescriptor != null) {
                inputStream = new FileInputStream(parcelFileDescriptor.getFileDescriptor());
            }
        } catch (FileNotFoundException e) {
            RLog.e(TAG, "getFileInputStreamWithUri: ", e);
        }
        return inputStream;
    }

    /**
     * @param context 上下文
     * @param file    文件
     * @param type    KitStorageUtils.MediaType
     * @return 保存媒体数据到公有目录返回结果
     */
    public static boolean saveMediaToPublicDir(Context context, File file, String type) {
        if (MediaType.IMAGE.equals(type)) {
            return copyImageToPublicDir(context, file);
        } else if (MediaType.VIDEO.equals(type)) {
            return copyVideoToPublicDir(context, file);
        } else {
            RLog.i(TAG, "type is error");
            return false;
        }
    }
}
