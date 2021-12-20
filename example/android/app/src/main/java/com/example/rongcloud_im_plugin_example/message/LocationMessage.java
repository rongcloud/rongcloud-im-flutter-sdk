package com.example.rongcloud_im_plugin_example.message;

import android.net.Uri;
import android.os.Parcel;
import android.text.TextUtils;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import io.rong.common.ParcelUtils;
import io.rong.imlib.MessageTag;
import io.rong.imlib.model.MessageContent;
import io.rong.imlib.model.UserInfo;

/**
 * 地理位置消息类
 * <p>地理位置消息类，此消息会进行存储并计入未读消息数。</p>
 *
 * @group 内容类消息
 */
@MessageTag(value = "RC:LBSMsg", flag = MessageTag.ISCOUNTED | MessageTag.ISPERSISTED, messageHandler = LocationMessageHandler.class)
public final class LocationMessage extends MessageContent {

    private static final String TAG = LocationMessage.class.getSimpleName();
    // 经度
    private double mLat;
    // 纬度
    private double mLng;
    // 地图 POI 信息
    private String mPoi;
    // Base64 数据
    private String mBase64;
    // 地图缩略图地址
    private Uri mImgUri;

    @Override
    public byte[] encode() {

        JSONObject jsonObj = new JSONObject();

        try {
            if (!TextUtils.isEmpty(mBase64)) {
                jsonObj.put("content", mBase64);
            } else {
                //为了将缩略图地址存储在数据库中，地理位置重传时会使用到
                //用户重启应用后，依然能从数据库读取发送失败的地理位置信息，再次重发
                if (mImgUri != null)
                    jsonObj.put("content", mImgUri);
            }

            jsonObj.put("latitude", mLat);
            jsonObj.put("longitude", mLng);

            if (!TextUtils.isEmpty(getExtra()))
                jsonObj.put("extra", getExtra());

            if (!TextUtils.isEmpty(mPoi))
                jsonObj.put("poi", mPoi);

            if (getJSONUserInfo() != null) {
                jsonObj.putOpt("user", getJSONUserInfo());
            }
            jsonObj.put("isBurnAfterRead", isDestruct());
            jsonObj.put("burnDuration", getDestructTime());

        } catch (JSONException e) {
            Log.e("JSONException", e.getMessage());
        }

        mBase64 = null;
        return jsonObj.toString().getBytes();
    }

    public LocationMessage(byte[] data) {

        String jsonStr = new String(data);

        try {
            JSONObject jsonObj = new JSONObject(jsonStr);

            setLat(jsonObj.getDouble("latitude"));
            setLng(jsonObj.getDouble("longitude"));

            if (jsonObj.has("content")) {
                setBase64(jsonObj.optString("content"));
            }

            if (jsonObj.has("extra"))
                setExtra(jsonObj.optString("extra"));
            setPoi(jsonObj.optString("poi"));

            if (jsonObj.has("user"))
                setUserInfo(parseJsonToUserInfo(jsonObj.getJSONObject("user")));
            if (jsonObj.has("isBurnAfterRead")) {
                setDestruct(jsonObj.getBoolean("isBurnAfterRead"));
            }
            if (jsonObj.has("burnDuration")) {
                setDestructTime(jsonObj.getLong("burnDuration"));
            }
        } catch (JSONException e) {
            Log.e("JSONException", e.getMessage());
        }
    }

    /**
     * 生成 LocationMessage 对象。
     *
     * @param lat    纬度。
     * @param lng    经度。
     * @param poi    poi 信息。
     * @param imgUri 地图缩率图地址。
     * @return LocationMessage 实例对象。
     */
    public static LocationMessage obtain(double lat, double lng, String poi, Uri imgUri) {
        return new LocationMessage(lat, lng, poi, imgUri);
    }

    private LocationMessage(double lat, double lng, String poi, Uri imgUri) {
        this.mLat = lat;
        this.mLng = lng;
        this.mPoi = poi;
        this.mImgUri = imgUri;
    }

    /**
     * 获取纬度。
     *
     * @return 纬度。
     */
    public double getLat() {
        return mLat;
    }

    /**
     * 设置纬度。
     *
     * @param lat 纬度。
     */
    public void setLat(double lat) {
        this.mLat = lat;
    }

    /**
     * 获取经度。
     *
     * @return 经度。
     */
    public double getLng() {
        return mLng;
    }

    /**
     * 设置经度。
     *
     * @param lng 经度。
     */
    public void setLng(double lng) {
        this.mLng = lng;
    }

    /**
     * 获取 POI 信息。
     *
     * @return POI 信息。
     */
    public String getPoi() {
        return mPoi;
    }

    /**
     * 设置 POI 信息。
     *
     * @param poi POI 信息。
     */
    public void setPoi(String poi) {
        this.mPoi = poi;
    }

    /**
     * 获取需要传递的 Base64 数据。
     *
     * @return Base64 数据。
     */
    public String getBase64() {
        return mBase64;
    }

    /**
     * 设置需要传递的 Base64 数据
     *
     * @param base64 Base64 数据。
     */
    public void setBase64(String base64) {
        this.mBase64 = base64;
    }

    /**
     * 获取地图缩略图地址。
     *
     * @return 地图缩略图地址。
     */
    public Uri getImgUri() {
        return mImgUri;
    }

    /**
     * 设置地图缩略图地址。
     *
     * @param imgUri 地图缩略图地址。
     */
    public void setImgUri(Uri imgUri) {
        this.mImgUri = imgUri;
    }

    /**
     * 描述了包含在 Parcelable 对象排列信息中的特殊对象的类型。
     *
     * @return 一个标志位，表明 Parcelable 对象特殊对象类型集合的排列。
     */
    @Override
    public int describeContents() {
        return 0;
    }

    /**
     * 将类的数据写入外部提供的 Parcel 中。
     *
     * @param dest  对象被写入的 Parcel。
     * @param flags 对象如何被写入的附加标志，可能是 0 或 PARCELABLE_WRITE_RETURN_VALUE。
     */
    @Override
    public void writeToParcel(Parcel dest, int flags) {
        ParcelUtils.writeToParcel(dest, getExtra());
        ParcelUtils.writeToParcel(dest, mLat);
        ParcelUtils.writeToParcel(dest, mLng);
        ParcelUtils.writeToParcel(dest, mPoi);
        ParcelUtils.writeToParcel(dest, mImgUri);
        ParcelUtils.writeToParcel(dest, getUserInfo());
        ParcelUtils.writeToParcel(dest, isDestruct() ? 1 : 0);
        ParcelUtils.writeToParcel(dest, getDestructTime());
        ParcelUtils.writeToParcel(dest, getBase64());
    }

    public LocationMessage(Parcel in) {
        setExtra(ParcelUtils.readFromParcel(in));
        mLat = ParcelUtils.readDoubleFromParcel(in);
        mLng = ParcelUtils.readDoubleFromParcel(in);
        mPoi = ParcelUtils.readFromParcel(in);
        mImgUri = ParcelUtils.readFromParcel(in, Uri.class);
        setUserInfo(ParcelUtils.readFromParcel(in, UserInfo.class));
        setDestruct(ParcelUtils.readIntFromParcel(in) == 1);
        setDestructTime(ParcelUtils.readLongFromParcel(in));
        setBase64(ParcelUtils.readFromParcel(in));
    }


    /**
     * 读取接口，目的是要从 Parcel 中构造一个实现了 Parcelable 的类的实例处理。
     */
    public static final Creator<LocationMessage> CREATOR = new Creator<LocationMessage>() {

        @Override
        public LocationMessage createFromParcel(Parcel source) {
            return new LocationMessage(source);
        }

        @Override
        public LocationMessage[] newArray(int size) {
            return new LocationMessage[size];
        }
    };
}
