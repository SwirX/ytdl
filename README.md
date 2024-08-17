# YTDL

A Flutter package that allows you to download videos and audio from YouTube on both Android and iOS devices. This package provides simple methods for fetching video/audio details and saving them to the user's device.

## Features

- Download YouTube videos
- Download YouTube audio
- Automatic merging of video and audio streams
- Currently supports the highest available quality

## Installation

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  ytdl: ^1.0.0
```

## Usage

### Permissions

To use this package, you must have read and write access to the device's storage. Ensure you request the following permissions:

### Android

Add the following permissions to your AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS

Add the following permissions to your Info.plist:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need your permission to save videos to your photo library.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need your permission to access your photo library.</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need your permission to access the microphone.</string>
<key>NSCameraUsageDescription</key>
<string>We need your permission to access the camera.</string>
```

## Example

Here's an example of how to use the package to download videos and audio:

```dart
Copy code
import 'package:ytdl/ytdl.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  final youtubeDownloader = YoutubeDownloader();

  // Example YouTube video ID
  final videoId = 'dQw4w9WgXcQ';

  // Get the app's directory
  final directory = await getApplicationDocumentsDirectory();

  // Download the video
  await youtubeDownloader.downloadVideo(videoId, directory.path);

  // Download the audio
  await youtubeDownloader.downloadAudio(videoId, directory.path);

  print('Download completed!');
}
```

### API

`getResults(String id)`: Fetches video information from YouTube.
`downloadVideo(String id, String path)`: Downloads the video to the specified path.
`downloadAudio(String id, String path)`: Downloads the audio to the specified path.

### Classes

#### 

## Roadmap

[x] Download Audio
[x] Download Video
[ ] Support multiple video and audio formats
[ ] Add support for selecting video quality
[ ] Improve error handling
[ ] Support more video platforms

## Contributing

Contributions are welcome! Please submit a pull request or open an issue for any bugs or feature requests.

## License

MIT License