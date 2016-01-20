package xwang.cordova.alipay;

import android.util.Log;

import com.alipay.sdk.app.PayTask;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONException;
import org.json.JSONObject;

public class Alipay extends CordovaPlugin {
    public static final String TAG = "xwang.cordova.alipay";
    public static final String ERROR_INVALID_PARAMETERS = "参数错误";

    @Override
    protected void pluginInitialize() {
        super.pluginInitialize();

        Log.d(TAG, "alipay plugin initialized.");
    }

    @Override
    public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {
        if(action.equals("pay")) {
            return pay(args, callbackContext);
        }
        return true;
    }

    protected boolean pay(CordovaArgs args, final CallbackContext callbackContext) {
        final String order;
        try {
            order = args.getString(0);
        } catch (JSONException e) {
            callbackContext.error(ERROR_INVALID_PARAMETERS);
            return true;
        }

        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                PayTask payTask = new PayTask(cordova.getActivity());
                String result = payTask.pay(order, true);
                try {
                    callbackContext.success(parsePayResult(result));
                } catch (JSONException e) {
                    callbackContext.error(e.getMessage());
                }
            }
        });

        sendNoResultPluginResult(callbackContext);
        return true;
    }

    private JSONObject parsePayResult(String payResult) throws JSONException{
        String resultStatus = "", memo = "", result = "";
        String[] keyPairs = payResult.split(";");
        for(String keyPair : keyPairs) {
            if (keyPair.startsWith("resultStatus")) {
                resultStatus = gatValue(keyPair, "resultStatus");
            }
            if (keyPair.startsWith("result")) {
                result = gatValue(keyPair, "result");
            }
            if (keyPair.startsWith("memo")) {
                memo = gatValue(keyPair, "memo");
            }
        }
        String json = "{resultStatus: " + resultStatus + ", memo: \"" + memo + "\", result: \"" + result +"\"}";
        return new JSONObject(json);
    }

    private String gatValue(String content, String key) {
        String prefix = key + "={";
        return content.substring(content.indexOf(prefix) + prefix.length(), content.lastIndexOf("}"));
    }

    private void sendNoResultPluginResult(CallbackContext callbackContext) {
        PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);
    }
}