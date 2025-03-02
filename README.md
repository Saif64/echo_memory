## Test your memory and focus by repeating color sequences. How far can you go?

<p float="left">
   <img src="https://github.com/Saif64/echo_memory/blob/master/ss/image1.png" width="220" />
  <img src="https://github.com/Saif64/echo_memory/blob/master/ss/image2.png" width="220" />
  <img src="https://github.com/Saif64/echo_memory/blob/master/ss/image3.png" width="220" />
  <img src="https://github.com/Saif64/echo_memory/blob/master/ss/image4.png" width="220" />
  <br>
  
  <img src="https://github.com/Saif64/echo_memory/blob/master/ss/home.png" width="220" />
  <img src="https://github.com/Saif64/echo_memory/blob/master/ss/daily.png" width="220" />
  <img src="https://github.com/Saif64/echo_memory/blob/master/ss/diff.png" width="220" />
  <img src="https://github.com/Saif64/echo_memory/blob/master/ss/game.png" width="220" />
 
</p>



### Sharpen your memory with Echo Memory! 🧠✨ Test your focus and recall skills by repeating color sequences that get more challenging with each level. How far can you go?

## 🔥 Features:
- ✅ Simple & addictive gameplay
- ✅ Increasing difficulty to challenge your brain
- ✅ Clean & lightweight design
- ✅ Perfect for all ages

Train your memory and have fun! Download now and start playing! 🎮

##### To run the app project first install ***fvm*** on your system.

***for IOS build it's preferred to archive from xCode and upload the symbol files to as well.***

## run:

```
fvm use 3.29.0
```

```
configure firebase credantials and setup the firebase project on this device
```

```
fvm flutter pub get
fvm flutter run
```

## To give build for Android

```
fvm flutter build appbundle --release --obfuscate --split-debug-info=./debug_info
fvm flutter build apk --release --obfuscate --split-debug-info=./debug_info
```

## for IOS build

```
fvm flutter build ios --release --obfuscate --split-debug-info=./debug_info
fvm flutter build ipa --release --obfuscate --split-debug-info=./debug_info
```

## for IOS upload-symbols

```
Pods/FirebaseCrashlytics/upload-symbols -gsp Runner/GoogleService-Info.plist -p ios build/Runner.xcarchive/dSYMs
```
 
