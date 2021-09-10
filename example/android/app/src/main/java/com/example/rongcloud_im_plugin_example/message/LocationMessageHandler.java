package com.example.rongcloud_im_plugin_example.message;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.net.Uri;
import android.text.TextUtils;
import android.util.Base64;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import io.rong.common.FileUtils;
import io.rong.common.RLog;
import io.rong.imlib.NativeClient;
import io.rong.imlib.common.NetUtils;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.MessageContent;
import io.rong.message.MessageHandler;
import io.rong.message.ReferenceMessage;
import io.rong.message.utils.BitmapUtil;

public class LocationMessageHandler extends MessageHandler<LocationMessage> {
    private final static String TAG = "LocationMessageHandler";

    private static int THUMB_WIDTH = 408;
    private static int THUMB_HEIGHT = 240;

    private static int THUMB_COMPRESSED_QUALITY = 70;

    public LocationMessageHandler(Context context) {
        super(context);
    }

    @Override
    public void decodeMessage(Message message, LocationMessage content) {
        String name = message.getMessageId() + "";
        if (message.getMessageId() == 0) {
            name = message.getSentTime() + "";
        }
        Uri uri = NativeClient.getInstance().obtainMediaFileSavedUri();
        File file = new File(uri.toString() + name);
        if (file.exists()) {
            content.setImgUri(Uri.fromFile(file));
            return;
        }
        if (content != null) {
            String base64 = content.getBase64();
            if (!TextUtils.isEmpty(base64)) {
                if (base64.startsWith("http")) {
                    content.setImgUri(Uri.parse(base64));
                    content.setBase64(null);
                } else {
                    try {
                        byte[] audio = Base64.decode(content.getBase64(), Base64.NO_WRAP);
                        file = FileUtils.byte2File(audio, uri.toString(), name + "");
                        if (content.getImgUri() == null) {
                            if (file != null && file.exists()) {
                                content.setImgUri(Uri.fromFile(file));
                            } else {
                                RLog.e(TAG, "getImgUri is null");
                            }
                        }
                    } catch (IllegalArgumentException e) {
                        RLog.e(TAG, "Not Base64 Content!");
                        RLog.e(TAG, "IllegalArgumentException", e);
                    }
                    message.setContent(content);
                    content.setBase64(null);
                }
            }
        }
    }

    @Override
    public void encodeMessage(Message message) {
        LocationMessage content;
        if (message.getContent() instanceof ReferenceMessage) {
            MessageContent refContent = ((ReferenceMessage) message.getContent()).getReferenceContent();
            if (refContent instanceof LocationMessage) {
                content = (LocationMessage) refContent;
            } else {
                return;
            }
        } else if (message.getContent() instanceof LocationMessage) {
            content = (LocationMessage) message.getContent();
        } else {
            return;
        }
        if (content.getImgUri() == null) {
            RLog.w(TAG, "No thumbnail uri.");
            if (mHandleMessageListener != null) {
                mHandleMessageListener.onHandleResult(message, 0);
            }
            return;
        }
        File file;
        Uri uri = NativeClient.getInstance().obtainMediaFileSavedUri();
        String thumbnailPath;
        String scheme = content.getImgUri().getScheme();
        if (!TextUtils.isEmpty(scheme) && scheme.toLowerCase().equals("file")) {
            thumbnailPath = content.getImgUri().getPath();
        } else {
            file = loadLocationThumbnail(content, message.getSentTime() + "");
            thumbnailPath = file != null ? file.getPath() : null;
        }
        if (thumbnailPath == null) {
            RLog.e(TAG, "load thumbnailPath null!");
            if (mHandleMessageListener != null) {
                mHandleMessageListener.onHandleResult(message, -1);
            }
            return;
        }
        Resources resources = getContext().getResources();
        try {
            THUMB_COMPRESSED_QUALITY = resources.getInteger(resources.getIdentifier("rc_location_thumb_quality", "integer", getContext().getPackageName()));
            THUMB_WIDTH = resources.getInteger(resources.getIdentifier("rc_location_thumb_width", "integer", getContext().getPackageName()));
            THUMB_HEIGHT = resources.getInteger(resources.getIdentifier("rc_location_thumb_height", "integer", getContext().getPackageName()));
        } catch (Resources.NotFoundException e) {
            e.printStackTrace();
        }
        THUMB_WIDTH = (int) (THUMB_WIDTH / 2 * resources.getDisplayMetrics().density + 0.5f);
        THUMB_HEIGHT = (int) (THUMB_HEIGHT / 2 * resources.getDisplayMetrics().density + 0.5f);
        try {
            Bitmap bitmap = BitmapUtil.interceptBitmap(thumbnailPath, THUMB_WIDTH, THUMB_HEIGHT);
            if (bitmap != null) {
                ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                bitmap.compress(Bitmap.CompressFormat.JPEG, THUMB_COMPRESSED_QUALITY, outputStream);
                byte[] data = outputStream.toByteArray();
                outputStream.close();

                String base64 = Base64.encodeToString(data, Base64.NO_WRAP);
                content.setBase64(base64);
                file = FileUtils.byte2File(data, uri.toString(), message.getMessageId() + "");
                if (file != null && file.exists()) {
                    content.setImgUri(Uri.fromFile(file));
                }
                if (!bitmap.isRecycled())
                    bitmap.recycle();
                if (mHandleMessageListener != null) {
                    mHandleMessageListener.onHandleResult(message, 0);
                }
            } else {
                RLog.e(TAG, "get null bitmap!");
                if (mHandleMessageListener != null) {
                    mHandleMessageListener.onHandleResult(message, -1);
                }
            }
        } catch (Exception e) {
            RLog.e(TAG, "Not Base64 Content!");
            RLog.e(TAG, "Exception ", e);
            if (mHandleMessageListener != null) {
                mHandleMessageListener.onHandleResult(message, -1);
            }
        }
    }

    private File loadLocationThumbnail(LocationMessage content, String name) {
        File file = null;
        HttpURLConnection conn = null;
        int responseCode = 0;
        InputStream is = null;
        FileOutputStream os = null;

        if (getContext() == null) {
            return null;
        }

        try {
            Uri uri = content.getImgUri();
            URL url = new URL(uri.toString());
            conn = NetUtils.createURLConnection(url.toString());
            conn.setRequestMethod("GET");
            conn.setReadTimeout(3000);
            conn.connect();

            responseCode = conn.getResponseCode();
            if (responseCode >= 200 && responseCode < 300) {
                String path = FileUtils.getInternalCachePath(getContext(), "location");
                file = new File(path);
                if (!file.exists()) {
                    boolean successMkdir = file.mkdirs();
                    if (!successMkdir) {
                        RLog.e(TAG, "Created folders unSuccessfully");
                    }
                }

                file = new File(path, name);
                is = conn.getInputStream();
                os = new FileOutputStream(file);
                byte[] buffer = new byte[1024];
                int len;
                while ((len = is.read(buffer)) != -1) {
                    os.write(buffer, 0, len);
                }
            }
        } catch (Exception e) {
            RLog.e(TAG, "Exception ", e);
        } finally {
            if (conn != null) {
                conn.disconnect();
            }

            if (is != null) {
                try {
                    is.close();
                } catch (IOException e) {
                    RLog.d(TAG, "is close error");
                }
            }

            if (os != null) {
                try {
                    os.close();
                } catch (IOException e) {
                    RLog.d(TAG, "os close error");
                }
            }
            RLog.d(TAG, "loadLocationThumbnail result : " + responseCode);
        }
        return file;
    }
}
