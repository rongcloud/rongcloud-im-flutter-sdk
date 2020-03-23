package com.example.rongcloud_im_plugin;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.util.Base64;

import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.security.MessageDigest;

import io.rong.common.FileUtils;
import io.rong.common.RLog;
import io.rong.imlib.RongIMClient;
import io.rong.imlib.model.Message;
import io.rong.message.GIFMessage;
import io.rong.message.ImageMessage;
import io.rong.message.SightMessage;
import io.rong.message.utils.BitmapUtil;

import static android.provider.MediaStore.Video.Thumbnails.MINI_KIND;

import android.media.ThumbnailUtils;

public class RCMessageHandler {

    private static int COMPRESSED_SIZE = 960;
    private static int COMPRESSED_QUALITY = 85;
    private static int MAX_ORIGINAL_IMAGE_SIZE = 200;//200K
    private static int THUMB_COMPRESSED_SIZE = 240;
    private static int THUMB_COMPRESSED_MIN_SIZE = 100;
    private static int THUMB_COMPRESSED_QUALITY = 30;
    private final static String IMAGE_LOCAL_PATH = "/image/local/";
    private final static String IMAGE_THUMBNAIL_PATH = "/image/thumbnail/";

    private final static String VIDEO_THUMBNAIL_PATH = "/video/thumbnail/";

    //ImageMessageHandler encodeMessage 方法的副本
    static public void encodeImageMessage(Message message) {
        Context context = RCIMFlutterWrapper.getInstance().getMainContext();
        File file = context.getFilesDir();
        String path = file.getAbsolutePath();

        Uri uri = obtainMediaFileSavedUri();

        ImageMessage model = (ImageMessage) message.getContent();
        String name = message.getMessageId() + ".jpg";
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        Resources resources = context.getResources();

        try {
            COMPRESSED_QUALITY = resources.getInteger(resources.getIdentifier("rc_image_quality", "integer", context.getPackageName()));
            COMPRESSED_SIZE = resources.getInteger(resources.getIdentifier("rc_image_size", "integer", context.getPackageName()));
            MAX_ORIGINAL_IMAGE_SIZE = resources.getInteger(resources.getIdentifier("rc_max_original_image_size", "integer", context.getPackageName()));
        } catch (Resources.NotFoundException var22) {
            var22.printStackTrace();
        }

        Bitmap bitmap;
        if (model.getThumUri() != null && model.getThumUri().getScheme() != null && model.getThumUri().getScheme().equals("file")) {
            file = new File(uri.toString() + "/image/thumbnail/" + name);
            byte[] data;
            if (file.exists()) {
                model.setThumUri(Uri.parse("file://" + uri.toString() + "/image/thumbnail/" + name));
                data = FileUtils.file2byte(file);
                if (data != null) {
                    model.setBase64(Base64.encodeToString(data, 2));
                }
            } else {
                try {
                    String thumbPath = model.getThumUri().toString().substring(5);
                    RLog.d("ImageMessageHandler", "beforeEncodeMessage Thumbnail not save yet! " + thumbPath);
                    BitmapFactory.decodeFile(thumbPath, options);
                    String imageFormat = options.outMimeType != null ? options.outMimeType : "";
                    RLog.d("ImageMessageHandler", "Image format:" + imageFormat);
                    if (options.outWidth <= THUMB_COMPRESSED_SIZE && options.outHeight <= THUMB_COMPRESSED_SIZE) {
                        byte var28 = -1;
                        switch (imageFormat.hashCode()) {
                            case -1487018032:
                                if (imageFormat.equals("image/webp")) {
                                    var28 = 1;
                                }
                                break;
                            case -879267568:
                                if (imageFormat.equals("image/gif")) {
                                    var28 = 0;
                                }
                        }

                        switch (var28) {
                            case 0:
                            case 1:
                                BitmapFactory.Options bmOptions = new BitmapFactory.Options();
                                bmOptions.inJustDecodeBounds = false;
                                bitmap = BitmapFactory.decodeFile(thumbPath, bmOptions);
                                ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                                bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);
                                data = outputStream.toByteArray();
                                outputStream.close();
                                if (data != null) {
                                    model.setBase64(Base64.encodeToString(data, 2));
                                    FileUtils.byte2File(data, uri.toString() + "/image/thumbnail/", name);
                                    model.setThumUri(Uri.parse("file://" + uri.toString() + "/image/thumbnail/" + name));
                                }

                                if (!bitmap.isRecycled()) {
                                    bitmap.recycle();
                                }
                                break;
                            default:
                                File src = new File(thumbPath);
                                long fileSize = FileUtils.getFileSize(src);
                                if (fileSize > 20480L) {
                                    int sizeLimit = options.outWidth > options.outHeight ? options.outWidth : options.outHeight;
                                    Bitmap bitmapLargeFile = BitmapUtil.getThumbBitmap(context, model.getThumUri(), sizeLimit, THUMB_COMPRESSED_MIN_SIZE);
                                    if (bitmapLargeFile != null) {
                                        ByteArrayOutputStream outputStreamLargeFile = new ByteArrayOutputStream();
                                        bitmapLargeFile.compress(Bitmap.CompressFormat.JPEG, THUMB_COMPRESSED_QUALITY, outputStreamLargeFile);
                                        data = outputStreamLargeFile.toByteArray();
                                        model.setBase64(Base64.encodeToString(data, 2));
                                        outputStreamLargeFile.close();
                                        FileUtils.byte2File(data, uri.toString() + "/image/thumbnail/", name);
                                        model.setThumUri(Uri.parse("file://" + uri.toString() + "/image/thumbnail/" + name));
                                        if (!bitmapLargeFile.isRecycled()) {
                                            bitmapLargeFile.recycle();
                                        }
                                    }
                                } else {
                                    data = FileUtils.file2byte(src);
                                    if (data != null) {
                                        model.setBase64(Base64.encodeToString(data, 2));
                                        path = uri.toString() + "/image/thumbnail/";
                                        if (FileUtils.copyFile(src, path, name) != null) {
                                            model.setThumUri(Uri.parse("file://" + path + name));
                                        }
                                    }
                                }
                        }
                    } else {
                        bitmap = BitmapUtil.getThumbBitmap(context, model.getThumUri(), THUMB_COMPRESSED_SIZE, THUMB_COMPRESSED_MIN_SIZE);
                        if (bitmap != null) {
                            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                            bitmap.compress(Bitmap.CompressFormat.JPEG, THUMB_COMPRESSED_QUALITY, outputStream);
                            data = outputStream.toByteArray();
                            model.setBase64(Base64.encodeToString(data, 2));
                            outputStream.close();
                            FileUtils.byte2File(data, uri.toString() + "/image/thumbnail/", name);
                            model.setThumUri(Uri.parse("file://" + uri.toString() + "/image/thumbnail/" + name));
                            if (!bitmap.isRecycled()) {
                                bitmap.recycle();
                            }
                        }
                    }
                } catch (Exception var24) {
                    RLog.e("ImageMessageHandler", "Exception ", var24);
                }
            }
        }

        if (model.getLocalUri() != null && model.getLocalUri().getScheme() != null && model.getLocalUri().getScheme().equals("file")) {
            file = new File(uri.toString() + "/image/local/" + name);
            if (file.exists()) {
                model.setLocalUri(Uri.parse("file://" + uri.toString() + "/image/local/" + name));
            } else {
                try {
                    String localPath = model.getLocalUri().toString().substring(5);
                    BitmapFactory.decodeFile(localPath, options);
                    file = new File(localPath);
                    long fileSize = file.length() / 1024L;
                    if ((options.outWidth > COMPRESSED_SIZE || options.outHeight > COMPRESSED_SIZE) && !model.isFull() && fileSize > (long) MAX_ORIGINAL_IMAGE_SIZE) {
                        bitmap = BitmapUtil.getResizedBitmap(context, model.getLocalUri(), COMPRESSED_SIZE, COMPRESSED_SIZE);
                        if (bitmap != null) {
                            String dir = uri.toString() + "/image/local/";
                            file = new File(dir);
                            if (!file.exists()) {
                                file.mkdirs();
                            }

                            file = new File(dir + name);
                            BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(file));
                            bitmap.compress(Bitmap.CompressFormat.JPEG, COMPRESSED_QUALITY, bos);
                            bos.close();
                            model.setLocalUri(Uri.parse("file://" + dir + name));
                            if (!bitmap.isRecycled()) {
                                bitmap.recycle();
                            }
                        }
                    } else if (FileUtils.copyFile(new File(localPath), uri.toString() + "/image/local/", name) != null) {
                        model.setLocalUri(Uri.parse("file://" + uri.toString() + "/image/local/" + name));
                    }
                } catch (IOException var23) {
                    RLog.e("ImageMessageHandler", "IOException  ", var23);
                    RLog.e("ImageMessageHandler", "beforeEncodeMessage IOException");
                }
            }
        }

    }

    static public void encodeSightMessage(Message message) {
        String TAG = "encodeSightMessage";
        SightMessage model = (SightMessage) message.getContent();
        Uri uri = obtainMediaFileSavedUri();
        String name = message.getMessageId() + ".jpg";

        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        byte[] data;
        if (model.getThumbUri() != null
                && model.getThumbUri().getScheme() != null
                && model.getThumbUri().getScheme().equals("file")) {

            File file = new File(uri.toString() + VIDEO_THUMBNAIL_PATH + name);
            if (file.exists()) {
                model.setThumbUri(Uri.parse("file://" + uri.toString() + VIDEO_THUMBNAIL_PATH + name));
                data = FileUtils.file2byte(file);
                if (data != null) {
                    model.setBase64(Base64.encodeToString(data, Base64.NO_WRAP));
                }
                return;
            } else {
                String thumbPath = model.getThumbUri().toString().substring(5);
                File src = new File(thumbPath);
                data = FileUtils.file2byte(src);
                if (data != null) {
                    model.setBase64(Base64.encodeToString(data, Base64.NO_WRAP));
                    String path = uri.toString() + VIDEO_THUMBNAIL_PATH;
                    if ((FileUtils.copyFile(src, path, name)) != null) {
                        model.setThumbUri(Uri.parse("file://" + path + name));
                        return;
                    }
                }
            }
        }
        try {
            String videoPath = model.getLocalPath().toString().substring(5);
            RLog.d(TAG, "beforeEncodeMessage Thumbnail not save yet! " + videoPath);
            Bitmap bitmap = ThumbnailUtils.createVideoThumbnail(videoPath, MINI_KIND);
            if (bitmap != null) {
                ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                bitmap.compress(Bitmap.CompressFormat.JPEG, THUMB_COMPRESSED_QUALITY, outputStream);
                data = outputStream.toByteArray();
                model.setBase64(Base64.encodeToString(data, Base64.NO_WRAP));
                outputStream.close();
                FileUtils.byte2File(data, uri.toString() + VIDEO_THUMBNAIL_PATH, name);
                model.setThumbUri(Uri.parse("file://" + uri.toString() + VIDEO_THUMBNAIL_PATH + name));
                if (!bitmap.isRecycled()) {
                    bitmap.recycle();
                }
            }
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            RLog.e(TAG, "beforeEncodeMessage Not Base64 Content!");
        } catch (IOException e) {
            e.printStackTrace();
            RLog.e(TAG, "beforeEncodeMessage IOException");
        }
    }

    public static void encodeGifMessage(Message message) {
        GIFMessage model = (GIFMessage) message.getContent();
        Uri uri = obtainMediaFileSavedUri();
        String name = message.getMessageId() + ".gif";
        String localPath;

        if (model.getLocalPath() != null
                && model.getLocalPath().getScheme() != null
                && model.getLocalPath().getScheme().equals("file")) {

            localPath = uri.toString() + IMAGE_LOCAL_PATH + name;

            // copy 到缓存目录
            File file = new File(localPath);
            if (file.exists()) {
                model.setLocalUri(Uri.parse("file://" + uri.toString() + IMAGE_LOCAL_PATH + name));
            } else {
                localPath = model.getLocalUri().toString().substring(5);
                if ((FileUtils.copyFile(new File(localPath), uri.toString() + IMAGE_LOCAL_PATH, name)) != null) {
                    model.setLocalUri(Uri.parse("file://" + uri.toString() + IMAGE_LOCAL_PATH + name));
                }
            }

            Bitmap bitmap = BitmapFactory.decodeFile(localPath);

            if (bitmap != null) {
//                final int width = bitmap.getWidth();
//                final int height = bitmap.getHeight();

//                model.setWidth(width);
//                model.setHeight(height);
                final File imgFile = new File(localPath);
//                model.setGifDataSize(imgFile.length());
                model.setName(imgFile.getName());
            }


        }
    }

    static private String shortMD5(String... args) {
        try {
            StringBuilder builder = new StringBuilder();
            String[] var3 = args;
            int var4 = args.length;

            for (int var5 = 0; var5 < var4; ++var5) {
                String arg = var3[var5];
                builder.append(arg);
            }

            MessageDigest mdInst = MessageDigest.getInstance("MD5");
            mdInst.update(builder.toString().getBytes());
            byte[] mds = mdInst.digest();
            mds = Base64.encode(mds, 2);
            String result = new String(mds);
            result = result.replace("=", "").replace("+", "-").replace("/", "_").replace("\n", "");
            return result;
        } catch (Exception var7) {
            RLog.e("NativeClient", "shortMD5", var7);
            return "";
        }
    }

    static private Uri obtainMediaFileSavedUri() {

        Context context = RCIMFlutterWrapper.getInstance().getMainContext();
        String appkey = RCIMFlutterWrapper.getInstance().getAppkey();
        String currentUserId = RongIMClient.getInstance().getCurrentUserId();

        String key = shortMD5(appkey, currentUserId);
        File file = context.getFilesDir();
        String path = file.getAbsolutePath();
        Uri uri = Uri.parse(path + File.separator + key);
        return uri;
    }
}
