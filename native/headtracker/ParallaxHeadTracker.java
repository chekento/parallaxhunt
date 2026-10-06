package com.kosch.parallaxhunt;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.ImageFormat;
import android.graphics.Rect;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CaptureRequest;
import android.media.Image;
import android.media.ImageReader;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.SystemClock;
import android.util.Size;
import android.view.Surface;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.face.Face;
import com.google.mlkit.vision.face.FaceDetection;
import com.google.mlkit.vision.face.FaceDetector;
import com.google.mlkit.vision.face.FaceDetectorOptions;
import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.atomic.AtomicBoolean;

/** Front-camera head position/pose. Frames stay in memory and are never recorded. */
public final class ParallaxHeadTracker extends GodotPlugin {
    private static final int CAMERA_PERMISSION_REQUEST = 9426;
    private final HandlerThread cameraThread = new HandlerThread("ParallaxHeadCamera");
    private final Handler cameraHandler;
    private final FaceDetector detector;
    private final AtomicBoolean processing = new AtomicBoolean(false);
    private volatile boolean requested;
    private volatile boolean paused;
    private volatile int generation;
    private CameraDevice camera;
    private boolean opening;
    private CameraCaptureSession session;
    private ImageReader reader;
    private long lastFrame;
    private long lastFace;
    private String lastStatus = "";
    private int rotation;

    public ParallaxHeadTracker(Godot godot) {
        super(godot);
        cameraThread.start();
        cameraHandler = new Handler(cameraThread.getLooper());
        FaceDetectorOptions options = new FaceDetectorOptions.Builder()
                .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_FAST)
                .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_NONE)
                .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_NONE)
                .setMinFaceSize(0.12f).enableTracking().build();
        detector = FaceDetection.getClient(options);
    }

    @Override public String getPluginName() { return "ParallaxHeadTracker"; }
    @Override public Set<SignalInfo> getPluginSignals() {
        return new HashSet<>(Arrays.asList(
                new SignalInfo("head_pose", Double.class, Double.class, Double.class, Double.class, Double.class),
                new SignalInfo("tracking_status", String.class)));
    }
    private void status(String value) {
        if (value.equals(lastStatus)) return;
        lastStatus = value;
        runOnRenderThread(() -> emitSignal("tracking_status", value));
    }

    @UsedByGodot public void startTracking() {
        requested = true;
        Activity activity = getActivity();
        if (activity == null || paused) return;
        runOnUiThread(() -> {
            if (!requested || paused) return;
            if (activity.checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                status("Kamera-Zugriff erlauben");
                activity.requestPermissions(new String[]{Manifest.permission.CAMERA}, CAMERA_PERMISSION_REQUEST);
            } else cameraHandler.post(this::openCamera);
        });
    }

    @UsedByGodot public void stopTracking() {
        requested = false;
        cameraHandler.post(this::closeCamera);
        status("aus");
    }

    @Override public void onMainRequestPermissionsResult(int code, String[] permissions, int[] results) {
        if (code != CAMERA_PERMISSION_REQUEST) return;
        if (results.length > 0 && results[0] == PackageManager.PERMISSION_GRANTED && requested)
            cameraHandler.post(this::openCamera);
        else {
            requested = false;
            status("Kamera-Zugriff abgelehnt · Neigung aktiv");
        }
    }
    @Override public void onMainPause() {
        paused = true;
        cameraHandler.post(this::closeCamera);
    }
    @Override public void onMainResume() {
        paused = false;
        if (requested) startTracking();
    }
    @Override public void onMainDestroy() {
        requested = false;
        cameraHandler.post(() -> {
            closeCamera();
            detector.close();
            cameraThread.quitSafely();
        });
    }

    private void openCamera() {
        if (!requested || paused || camera != null || opening) return;
        Activity activity = getActivity();
        if (activity == null || activity.checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) return;
        closeCamera();
        opening = true;
        int token = ++generation;
        try {
            CameraManager manager = (CameraManager) activity.getSystemService(Context.CAMERA_SERVICE);
            String cameraId = null;
            CameraCharacteristics characteristics = null;
            for (String id : manager.getCameraIdList()) {
                CameraCharacteristics candidate = manager.getCameraCharacteristics(id);
                Integer facing = candidate.get(CameraCharacteristics.LENS_FACING);
                if (facing != null && facing == CameraCharacteristics.LENS_FACING_FRONT) {
                    cameraId = id;
                    characteristics = candidate;
                    break;
                }
            }
            if (cameraId == null || characteristics == null) {
                closeCamera();
                status("Keine Frontkamera · Neigung aktiv");
                return;
            }
            int displayRotation = activity.getWindowManager().getDefaultDisplay().getRotation();
            int displayDegrees = displayRotation == Surface.ROTATION_90 ? 90 : displayRotation == Surface.ROTATION_180 ? 180 : displayRotation == Surface.ROTATION_270 ? 270 : 0;
            Integer sensor = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION);
            rotation = ((sensor == null ? 270 : sensor) + displayDegrees) % 360;
            Size chosen = new Size(640,480);
            android.hardware.camera2.params.StreamConfigurationMap map = characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
            Size[] sizes = map == null ? null : map.getOutputSizes(ImageFormat.YUV_420_888);
            if (sizes != null) {
                long best = Long.MAX_VALUE;
                for (Size size : sizes) {
                    long pixels = (long)size.getWidth()*size.getHeight();
                    if (size.getWidth() < 320 || size.getHeight() < 240) continue;
                    long difference = Math.abs(pixels-640L*480L);
                    if (difference < best) { best = difference; chosen = size; }
                }
            }
            final ImageReader cameraReader = ImageReader.newInstance(chosen.getWidth(),chosen.getHeight(),ImageFormat.YUV_420_888,3);
            reader = cameraReader;
            cameraReader.setOnImageAvailableListener(source -> analyze(source,token),cameraHandler);
            status("Gesicht suchen");
            manager.openCamera(cameraId,new CameraDevice.StateCallback() {
                @Override public void onOpened(CameraDevice device) {
                    if (token != generation || !requested || paused) { device.close(); return; }
                    camera = device;
                    opening = false;
                    try {
                        CaptureRequest.Builder request = device.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);
                        request.addTarget(cameraReader.getSurface());
                        request.set(CaptureRequest.CONTROL_AF_MODE,CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_VIDEO);
                        device.createCaptureSession(Arrays.asList(cameraReader.getSurface()),new CameraCaptureSession.StateCallback() {
                            @Override public void onConfigured(CameraCaptureSession configured) {
                                if (token != generation || !requested || paused) { configured.close(); return; }
                                session = configured;
                                try { configured.setRepeatingRequest(request.build(),null,cameraHandler); }
                                catch (Exception error) { status("Kamera unterbrochen · Neigung aktiv"); closeCamera(); }
                            }
                            @Override public void onConfigureFailed(CameraCaptureSession failed) {
                                failed.close();
                                status("Kamera nicht bereit · Neigung aktiv");
                                closeCamera();
                            }
                        },cameraHandler);
                    } catch (Exception error) { status("Kamera nicht bereit · Neigung aktiv"); closeCamera(); }
                }
                @Override public void onDisconnected(CameraDevice device) {
                    device.close();
                    if (token == generation) { camera = null; closeCamera(); status("Kamera unterbrochen · Neigung aktiv"); }
                }
                @Override public void onError(CameraDevice device, int error) {
                    device.close();
                    if (token == generation) { camera = null; closeCamera(); status("Kamera belegt · Neigung aktiv"); }
                }
            },cameraHandler);
        } catch (Exception error) { closeCamera(); status("Kamera nicht verfügbar · Neigung aktiv"); }
    }

    private void analyze(ImageReader source, int token) {
        Image frame;
        try { frame = source.acquireLatestImage(); }
        catch (IllegalStateException error) { return; }
        if (frame == null) return;
        long now = SystemClock.elapsedRealtime();
        if (token != generation || !requested || paused || now-lastFrame<80 || !processing.compareAndSet(false,true)) {
            frame.close();
            return;
        }
        lastFrame = now;
        final int frameRotation = rotation;
        final int width = frameRotation%180 == 0 ? frame.getWidth() : frame.getHeight();
        final int height = frameRotation%180 == 0 ? frame.getHeight() : frame.getWidth();
        try {
            InputImage input = InputImage.fromMediaImage(frame,frameRotation);
            detector.process(input)
                .addOnSuccessListener(faces -> {
                    if (token != generation || !requested || paused) return;
                    Face largest = null;
                    for (Face face : faces) {
                        if (largest == null || face.getBoundingBox().width()*face.getBoundingBox().height() > largest.getBoundingBox().width()*largest.getBoundingBox().height()) largest = face;
                    }
                    if (largest == null) {
                        if (SystemClock.elapsedRealtime()-lastFace>600) status("Gesicht suchen · Neigung aktiv");
                        return;
                    }
                    Rect bounds = largest.getBoundingBox();
                    double x = -(bounds.exactCenterX()/width-0.5)*2.0;
                    double y = (bounds.exactCenterY()/height-0.5)*2.0;
                    double size = (double)bounds.height()/height;
                    double yaw = -largest.getHeadEulerAngleY();
                    double pitch = largest.getHeadEulerAngleX();
                    lastFace = SystemClock.elapsedRealtime();
                    status("Gesicht erkannt");
                    runOnRenderThread(() -> { if (token == generation && requested && !paused) emitSignal("head_pose",x,y,size,yaw,pitch); });
                })
                .addOnFailureListener(error -> { if (token == generation) status("Gesichtserkennung pausiert · Neigung aktiv"); })
                .addOnCompleteListener(task -> {
                    frame.close();
                    processing.set(false);
                    if (token != generation) source.close();
                });
        } catch (Exception error) {
            frame.close();
            processing.set(false);
            status("Gesichtserkennung pausiert · Neigung aktiv");
        }
    }

    private void closeCamera() {
        generation++;
        opening = false;
        if (session != null) { session.close(); session = null; }
        if (camera != null) { camera.close(); camera = null; }
        if (reader != null) {
            reader.setOnImageAvailableListener(null,null);
            if (!processing.get()) reader.close();
            reader = null;
        }
    }
}
