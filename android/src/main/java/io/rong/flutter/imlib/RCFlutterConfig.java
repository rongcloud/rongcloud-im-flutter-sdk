package io.rong.flutter.imlib;

import java.util.Map;

public class RCFlutterConfig {

    private boolean enablePersistentUserInfoCache;

    RCFlutterConfig(){

    }

    public void updateConf(Map map) {
        Map imMap = (Map)map.get("im");
        if(imMap != null) {
            setEnablePersistentUserInfoCache((boolean)imMap.get("enablePersistentUserInfoCache"));
        }
    }

    public boolean isEnablePersistentUserInfoCache() {
        return enablePersistentUserInfoCache;
    }

    public void setEnablePersistentUserInfoCache(boolean enablePersistentUserInfoCache) {
        this.enablePersistentUserInfoCache = enablePersistentUserInfoCache;
    }
}
