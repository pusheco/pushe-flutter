package co.ronash.pushe.flutter;

import android.content.Intent;
import android.support.v4.content.LocalBroadcastManager;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import co.ronash.pushe.Pushe;


/**
 * Service class to handle usage of Pushe and FCM together.
 * Fire base version that is compatible 5+
 */
public class PusheFcmService extends FirebaseMessagingService {

    public static final String ACTION_REMOTE_MESSAGE =
            "io.flutter.plugins.firebasemessaging.NOTIFICATION";
    public static final String EXTRA_REMOTE_MESSAGE = "notification";

    public static final String ACTION_TOKEN = "io.flutter.plugins.firebasemessaging.TOKEN";
    public static final String EXTRA_TOKEN = "token";

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {

        if (Pushe.getFcmHandler(this).onMessageReceived(remoteMessage)) return;

        Intent intent = new Intent(ACTION_REMOTE_MESSAGE);
        intent.putExtra(EXTRA_REMOTE_MESSAGE, remoteMessage);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }

    @Override
    public void onNewToken(String token) {

        Pushe.getFcmHandler(this).onNewToken(token);

        Intent intent = new Intent(ACTION_TOKEN);
        intent.putExtra(EXTRA_TOKEN, token);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }

    @Override
    public void onMessageSent(String s) {
        Pushe.getFcmHandler(this).onMessageSent(s);
    }

    @Override
    public void onSendError(String s, Exception e) {
        Pushe.getFcmHandler(this).onSendError(s, e);
    }

    @Override
    public void onDeletedMessages() {
        Pushe.getFcmHandler(this).onDeletedMessages();
    }
}
