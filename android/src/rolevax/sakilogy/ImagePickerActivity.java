package rolevax.sakilogy;

import org.qtproject.qt5.android.bindings.QtActivity;
import android.content.Intent;
import android.app.Activity;
import android.provider.MediaStore;
import android.content.CursorLoader;
import android.database.Cursor;
import android.util.Log;
import android.os.Bundle;
import android.view.View;

public class ImagePickerActivity extends QtActivity {
	public ImagePickerActivity() {
		m_instance = this;
	}

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if (hasFocus) {
            // hide the soft key bar
            getWindow().getDecorView().setSystemUiVisibility(
                    View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                            | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                            | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                            | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                            | View.SYSTEM_UI_FLAG_FULLSCREEN
                            | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
        }
    }
	
	public static Intent createChoosePhotoIntent() {
		Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
		intent.setType("image/*");
		return Intent.createChooser(intent, "Select Image");
	}

	public static String getPath(android.net.Uri uri) {
		String[] proj = { MediaStore.Images.Media.DATA };
		CursorLoader loader = new CursorLoader(m_instance.getApplicationContext(), uri, proj, null, null, null);
		Cursor cursor = loader.loadInBackground();
		int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
		cursor.moveToFirst();
		String result = cursor.getString(column_index);
		cursor.close();
		return result;
	}
	
	private static ImagePickerActivity m_instance;
}
