# check-game-java.bat

## 📋 Overview

A comprehensive JVM diagnostic utility that inspects a running Yahoo Puzzle Pirates game client and reports critical system information. This script was essential for troubleshooting during the Java 8 → Java 25 migration.

## 🎯 Problem Statement

When YPP upgraded to Java 25, many third-party tools broke due to compatibility issues and missing JVM flags. Users couldn't easily diagnose their installation or confirm whether the correct JVM configuration was in place. Different installation paths (AppData/Roaming vs AppData/Local) made it difficult to locate game instances programmatically.

## 💡 Solution

This script:
1. Locates the running YPP client via `jps` (Java Process Status)
2. Queries the live JVM using `jcmd` (Java Command)
3. Reports back all relevant diagnostic information

This allows both developers and users to quickly assess the health of their JVM environment without manual investigation.

## 🔧 How It Works

### Process Discovery
```batch
for /f "tokens=1" %%P in (
  '"%JPS%" -l ^| findstr /c:com.threerings.yohoho.client.YoApp'
) do set PID=%%P
```
Uses the bundled JDK's `jps.exe` to list all running Java processes and filters for the YPP client specifically.

### System Inspection
Once the PID is identified, the script queries:
- **Java Version** - `JCMD <PID> VM.version`
- **JVM Flags** - `JCMD <PID> VM.flags` (filtered for `EnableDynamicAgentLoading`)
- **System Properties** - Java home path, version details
- **Critical Flag Check** - Validates that `-XX:+EnableDynamicAgentLoading` is present (required for dynamic Java Agent attachment)

## 📊 Output Example

```
Found client with PID: 12345

===== GAME JAVA VERSION =====
openjdk version "25.0.1" 2024-10-08
OpenJDK Runtime Environment (build 25.0.1+8-LTS)

===== JVM FLAGS (checking for EnableDynamicAgentLoading) =====
-XX:+EnableDynamicAgentLoading

===== SYSTEM PROPERTIES =====
java.version = 25.0.1
java.home = C:\Users\Admin\AppData\Local\YPP\gizmo-jdk

CRITICAL: Look above for "EnableDynamicAgentLoading"
If it's missing or "false", the game client didn't get the flag!
```

## 🛠️ Prerequisites

- Yahoo Puzzle Pirates game client installed and running
- Game client must be logged in (for some operations)
- Bundled `gizmo-jdk` folder in the same directory as the script

## ⚙️ Key Technical Details

- **JPS Usage** - Finds Java processes without registry queries or hardcoded paths
- **JCMD Queries** - Non-intrusive inspection of running JVM without modification
- **Process Matching** - Uses specific class name (`com.threerings.yohoho.client.YoApp`) to avoid false positives
- **Flag Validation** - Specifically checks for `EnableDynamicAgentLoading`, which is required for the Java Agent approach

## 📌 Usage

```batch
check-game-java.bat
```

Simply run the script while YPP is running. It will display all diagnostic information and highlight whether critical flags are present.

## 🎓 Key Learnings

1. **JVM Process Management** - Understanding how to discover and inspect running Java processes
2. **Diagnostic Scripting** - Creating user-friendly diagnostic tools that gather system information
3. **Flag Validation** - Knowing which JVM flags are critical for specific use cases (in this case, dynamic instrumentation)
4. **Cross-Platform Installation Challenges** - Appreciating why process discovery is more reliable than path guessing

## 🚀 Legacy Status

This script is no longer required for YPP-Gizmo operation. Modern implementations handle configuration and verification automatically. However, it remains valuable as a diagnostic tool and demonstrates effective troubleshooting methodology.

## 📁 Related Files

- **[attach.bat](../attach/)** - Uses information from this diagnostic to attach Java Agents
- **[jlink.bat](../jlink/)** - Prepares the JRE that this diagnostic validates
