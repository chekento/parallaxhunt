@tool
extends EditorPlugin

var android_export: EditorExportPlugin

func _enter_tree() -> void:
    android_export=HeadTrackerExport.new()
    add_export_plugin(android_export)

func _exit_tree() -> void:
    remove_export_plugin(android_export)
    android_export=null

class HeadTrackerExport extends EditorExportPlugin:
    func _get_name() -> String:
        return "ParallaxHeadTracker"

    func _supports_platform(platform: EditorExportPlatform) -> bool:
        return platform is EditorExportPlatformAndroid

    func _get_android_dependencies(_platform: EditorExportPlatform, _debug: bool) -> PackedStringArray:
        return PackedStringArray(["com.google.mlkit:face-detection:16.1.7"])

    func _get_android_manifest_application_element_contents(_platform: EditorExportPlatform, _debug: bool) -> String:
        return '<meta-data android:name="org.godotengine.plugin.v2.ParallaxHeadTracker" android:value="com.kosch.parallaxhunt.ParallaxHeadTracker" />'

    func _export_begin(_features: PackedStringArray, _debug: bool, _path: String, _flags: int) -> void:
        if not FileAccess.file_exists("res://android/build/src/main/java/com/kosch/parallaxhunt/ParallaxHeadTracker.java"):
            push_error("Head tracker Android sources missing: run python3 scripts/prepare_android.py before exporting Android.")
