package mojaloop.fido2.fido2_client

import android.app.Activity
import android.app.Activity.RESULT_CANCELED
import android.app.Activity.RESULT_OK
import android.content.Intent
import android.preference.PreferenceManager
import android.provider.Settings.Global.putString
import android.util.Base64
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull;
import com.google.android.gms.fido.Fido
import com.google.android.gms.fido.fido2.api.common.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar

/** Fido2ClientPlugin */
public class Fido2ClientPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel : MethodChannel
    private lateinit var activity: Activity

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fido2_client")
        channel.setMethodCallHandler(this);
    }

    override fun onDetachedFromActivity() {
        // no-op
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity;
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // no-op
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "fido2_client")
            channel.setMethodCallHandler(Fido2ClientPlugin())
        }

        const val REGISTER_REQUEST_CODE = 1
        const val SIGN_REQUEST_CODE = 2
        const val RP_DOMAIN = "mojapay-test-rp.web.app"
        const val RP_NAME = "MojapayFido2"
        const val KEY_HANDLE_PREF = "KEY_HANDLE_PREF"
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "showToast" -> {
                val msg = call.argument<String>("msg")
                Toast.makeText(activity, msg, Toast.LENGTH_LONG).show()
            }
            "initiateRegistrationProcess" -> {
                // TODO Handle errors without arguments
                val challenge = call.argument<String>("challenge")!!
                val userId = call.argument<String>("userId")!!
                val username = call.argument<String>("username")!!
                initiateRegistrationProcess(challenge, userId, username)
            }
            "initiateSigningProcess" -> {
                val challenge = call.argument<String>("challenge")!!
                initiateSigningProcess(challenge)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initiateRegistrationProcess(challenge: String, userId: String, username: String) {
        val rpEntity = PublicKeyCredentialRpEntity(RP_DOMAIN, RP_NAME, null)
        // All the option parameters should come from the Relying Party / server
        val options = PublicKeyCredentialCreationOptions.Builder()
                .setRp(rpEntity)
                .setUser(
                        PublicKeyCredentialUserEntity(
                                userId.toByteArray(),
                                userId,
                                null,
                                username
                        )
                )
                .setChallenge(challenge.toByteArray())
                .setParameters(
                        listOf(
                                PublicKeyCredentialParameters(
                                        PublicKeyCredentialType.PUBLIC_KEY.toString(),
                                        EC2Algorithm.ES256.algoValue
                                )
                        )
                )
                .build()

        val fidoClient = Fido.getFido2ApiClient(activity)
        val result = fidoClient.getRegisterPendingIntent(options)
        result.addOnSuccessListener { pendingIntent ->
            if (pendingIntent != null) {
                // Start a FIDO2 registration request.
                activity.startIntentSenderForResult(
                        pendingIntent.intentSender,
                        REGISTER_REQUEST_CODE,
                        null,
                        0,
                        0,
                        0)
            }
        }

        result.addOnFailureListener {
            // TODO: Add on failure
        }
    }

    private fun initiateSigningProcess(challenge: String) {
        val options = PublicKeyCredentialRequestOptions.Builder()
                .setRpId(RP_DOMAIN)
                .setAllowList(
                        listOf(
                                PublicKeyCredentialDescriptor(
                                        PublicKeyCredentialType.PUBLIC_KEY.toString(),
                                        loadKeyHandle(),
                                        null
                                )
                        )
                )
                .setChallenge(challenge.toByteArray())
                .build()

        val fidoClient = Fido.getFido2ApiClient(activity)
        val result = fidoClient.getSignPendingIntent(options)
        result.addOnSuccessListener { pendingIntent ->
            if(pendingIntent != null) {
                activity.startIntentSenderForResult(pendingIntent.intentSender,
                        SIGN_REQUEST_CODE,
                        null,
                        0,
                        0,
                        0)
            }
        }

        result.addOnFailureListener {
            // TODO: Add on failure
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        when (resultCode) {
            RESULT_OK -> {
                data?.let {
                    if (it.hasExtra(Fido.FIDO2_KEY_ERROR_EXTRA)) {
                        //handleErrorResponse(data.getByteArrayExtra(Fido.FIDO2_KEY_ERROR_EXTRA))
                    } else if (it.hasExtra(Fido.FIDO2_KEY_RESPONSE_EXTRA)) {
                        val fido2Response = data.getByteArrayExtra(Fido.FIDO2_KEY_RESPONSE_EXTRA)
                        when (requestCode) {
                            REGISTER_REQUEST_CODE -> processRegisterResponse()
                            SIGN_REQUEST_CODE -> processSigningResponse()
                        }
                    }
                }
            }
            RESULT_CANCELED -> {
                // TODO: Handle
            }
        }
        return true
    }

    // TODO: need to send it back to native platform for handling
    private fun processRegisterResponse() {
    }

    // TODO: need to send it back to native platform for handling
    private fun processSigningResponse() {

    }

    private fun storeKeyHandle(keyHandle: ByteArray) {
        with(PreferenceManager.getDefaultSharedPreferences(activity).edit()) {
            putString(KEY_HANDLE_PREF, Base64.encodeToString(keyHandle, Base64.DEFAULT))
            apply()
        }
    }

    private fun loadKeyHandle(): ByteArray? {
        val keyHandleBase64 = PreferenceManager.getDefaultSharedPreferences(activity).getString(KEY_HANDLE_PREF, null)
                ?: return null
        return Base64.decode(keyHandleBase64, Base64.DEFAULT)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
