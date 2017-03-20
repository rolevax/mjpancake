package rolevax.sakilogy;

import org.qtproject.qt5.android.bindings.QtActivity;
import android.app.Activity;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.TaskStackBuilder;
import android.media.RingtoneManager;
import android.content.Intent;
import android.content.Context;
import android.content.CursorLoader;
import android.provider.MediaStore;
import android.database.Cursor;
import android.util.Log;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.net.Uri;
import android.view.View;

public class ImagePickerActivity extends QtActivity {
    private static ImagePickerActivity mInstance;
    private static NotificationManager mNotificationManager;
    private static Notification.Builder mBuilder;

    public ImagePickerActivity() {
        mInstance = this;
	}

    public static void forceImmersive() {
        if (mInstance != null) {
            mInstance.delayedHide(300);
        }
    }
	
    public static void popNotification()
    {
        if (mNotificationManager == null) {
            mNotificationManager = (NotificationManager)mInstance.getSystemService(
                Context.NOTIFICATION_SERVICE);
            mBuilder = new Notification.Builder(mInstance);
            mBuilder.setSmallIcon(R.drawable.icon);
            mBuilder.setContentTitle("Pancake Mahjong Notification");
            mBuilder.setAutoCancel(true);
            mBuilder.setPriority(Notification.PRIORITY_MAX);
            mBuilder.setDefaults(Notification.DEFAULT_ALL);

            Intent intent = new Intent(mInstance, ImagePickerActivity.class);
            intent.setAction(Intent.ACTION_MAIN);
            intent.addCategory(Intent.CATEGORY_LAUNCHER);
            PendingIntent pendingIntent = PendingIntent.getActivity(mInstance, 0, intent, 0);
            mBuilder.setContentIntent(pendingIntent);
        }

        mBuilder.setContentText("Table started");
        Notification noti = mBuilder.build();
        noti.sound = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        mNotificationManager.notify(1, noti);
    }

    public static Intent createChoosePhotoIntent() {
		Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
		intent.setType("image/*");
		return Intent.createChooser(intent, "Select Image");
	}

	public static String getPath(android.net.Uri uri) {
		String[] proj = { MediaStore.Images.Media.DATA };
        CursorLoader loader = new CursorLoader(mInstance.getApplicationContext(), uri, proj, null, null, null);
		Cursor cursor = loader.loadInBackground();
		int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
		cursor.moveToFirst();
		String result = cursor.getString(column_index);
		cursor.close();
		return result;
	}

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        // When the window loses focus (e.g. the action overflow is shown),
        // cancel any pending hide action. When the window gains focus,
        // hide the system UI.
        if (hasFocus) {
            delayedHide(300);
        } else {
            mHideHandler.removeMessages(0);
        }
    }

    private void hideSystemUI() {
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_LOW_PROFILE
                    | View.SYSTEM_UI_FLAG_IMMERSIVE);
    }

    private void showSystemUI() {
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
    }

    private final Handler mHideHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            hideSystemUI();
        }
    };

    private void delayedHide(int delayMillis) {
        mHideHandler.removeMessages(0);
        mHideHandler.sendEmptyMessageDelayed(0, delayMillis);
    }
}
