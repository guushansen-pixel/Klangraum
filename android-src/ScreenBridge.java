package __PACKAGE__;

import android.app.Activity;
import android.view.WindowManager;
import android.webkit.JavascriptInterface;

/**
 * Native Bruecke, aus der Web-App erreichbar als window.KrAndroid.
 *
 * setKeepScreenOn(on): Display bleibt an, solange Klang laeuft. Bewusst per
 *   Bruecke statt ueber den Schalter -KeepScreenOn des Templates: ohne
 *   laufenden Klang soll das Display normal ausgehen duerfen.
 * setBrightness(v): Helligkeit nur fuer dieses Fenster, 0..1 (fuer den
 *   Nachtbildschirm); ein negativer Wert gibt sie an das System zurueck.
 *
 * Beides braucht keine Berechtigung. Die Quelle liegt in
 * klangraum\android-src und wird von build.ps1 ins generierte Projekt kopiert.
 */
public class ScreenBridge {
    private final Activity activity;

    ScreenBridge(Activity activity) {
        this.activity = activity;
    }

    @JavascriptInterface
    public void setKeepScreenOn(final boolean on) {
        activity.runOnUiThread(() -> {
            if (on) {
                activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            } else {
                activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            }
        });
    }

    @JavascriptInterface
    public void setBrightness(final float value) {
        activity.runOnUiThread(() -> {
            WindowManager.LayoutParams lp = activity.getWindow().getAttributes();
            lp.screenBrightness = value < 0f
                ? WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
                : Math.max(0.01f, Math.min(1f, value));
            activity.getWindow().setAttributes(lp);
        });
    }
}
