"""Install the official Godot Android build template and the native head tracker."""
import argparse
import shutil
import zipfile
from pathlib import Path

parser=argparse.ArgumentParser()
parser.add_argument('--template',type=Path,required=True,help='Godot android_source.zip or export_templates.tpz')
args=parser.parse_args()
root=Path(__file__).resolve().parents[1]
target=root/'android/build'
target.mkdir(parents=True,exist_ok=True)
(root/'android/.gdignore').write_text('')
with zipfile.ZipFile(args.template) as archive:
    if 'templates/android_source.zip' in archive.namelist():
        import io
        with zipfile.ZipFile(io.BytesIO(archive.read('templates/android_source.zip'))) as source:
            source.extractall(target)
    else:
        archive.extractall(target)
for generated_import in target.rglob('*.import'):
    generated_import.unlink()
destination=target/'src/main/java/com/kosch/parallaxhunt'
destination.mkdir(parents=True,exist_ok=True)
shutil.copy2(root/'native/headtracker/ParallaxHeadTracker.java',destination/'ParallaxHeadTracker.java')
(root/'android/.build_version').write_text('4.7.2.stable')
print('ANDROID_SOURCES_READY · native front-camera tracker installed')
