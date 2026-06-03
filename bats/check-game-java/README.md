# check-game-java.bat

## 📋 Overview

A comprehensive JVM diagnostic utility that inspects a running Yahoo Puzzle Pirates (YPP) game client and reports critical system information. This script was essential during the Java 8 → Java 25 migration, helping users and developers quickly diagnose why YPP-Gizmo wasn't working.

## 🎯 Problem Statement

When YPP upgraded to Java 25, third-party tools like YPP-Gizmo broke due to compatibility issues and missing critical JVM flags. Users encountered several challenges:

- **Installation discovery**: Game installations could be in `AppData\Local`, `AppData\Roaming`, or other non-standard locations
- **Version uncertainty**: Many users had multiple Java installations and didn't know which version was running
- **Flag validation**: The Java Agent approach required `-XX:+EnableDynamicAgentLoading` flag, but users couldn't easily confirm it was set
- **Technical literacy**: Not all users could manually inspect JVM configurations

This script solved these problems by programmatically discovering the running game JVM and extracting all diagnostic information.

## 💡 Solution

The script automates the entire diagnostic workflow:

1. **Process Discovery** - Finds the YPP client JVM using `jps` (Java Process Status)
2. **Dynamic Querying** - Uses `jcmd` (Java Command) to inspect the live JVM without modifications
3. **Flag Validation** - Specifically checks for `EnableDynamicAgentLoading` flag
4. **System Inspection** - Collects Java version, paths, and all JVM flags
5. **User-Friendly Output** - Presents results clearly with critical information highlighted

## 🔧 How It Works

### Process Discovery
```batch
for /f "tokens=1" %%P in (
  '"%JPS%" -l ^| findstr /c:com.threerings.yohoho.client.YoApp'
) do set PID=%%P
```
Uses the bundled JDK's `jps.exe` to list all running Java processes and filters for the YPP client by its main class name (`com.threerings.yohoho.client.YoApp`).

### System Inspection
Once the PID is identified, the script queries:
- **Java Version** - `JCMD <PID> VM.version` - Full JVM build information
- **JVM Flags** - `JCMD <PID> VM.flags` - All active JVM flags (filtered for `EnableDynamicAgentLoading`)
- **System Properties** - Java home path, version details
- **Critical Flag Check** - Validates that `-XX:+EnableDynamicAgentLoading` is present

### Why EnableDynamicAgentLoading Matters
This flag enables Java Agents to attach to a running JVM. Without it:
- The `attach.bat` script cannot connect YPP-Gizmo to the game
- Dynamic instrumentation becomes impossible
- Users are blocked from using third-party tools

The good news: This flag comes naturally with the YPP game client. If it's missing, users can manually set it.

## 📊 Output Example

```
Looking for Puzzle Pirates client...
Found client with PID: 12345

===== GAME JAVA VERSION =====
openjdk version "25.0.1" 2024-10-08
OpenJDK Runtime Environment (build 25.0.1+8-LTS)

===== JVM FLAGS (checking for EnableDynamicAgentLoading) =====
-XX:+EnableDynamicAgentLoading

===== ALL JVM FLAGS =====
-XX:+EnableDynamicAgentLoading
-XX:+UseG1GC
-Xms512M
-Xmx2G

===== SYSTEM PROPERTIES =====
java.version = 25.0.1
java.home = C:\Users\Admin\AppData\Local\YPP\gizmo-jdk

===== YOUR GIZMO-JDK JAVA VERSION =====
openjdk version "25.0.1" 2024-10-08

CRITICAL: Look above for "EnableDynamicAgentLoading"
If it's missing or "false", the game client didn't get the flag!
```

## 🛠️ Prerequisites

- Yahoo Puzzle Pirates game client installed and running
- Game must be logged in (for some operations)
- Bundled `gizmo-jdk` folder (provided with YPP-Gizmo)
- Windows system with Command Prompt access

## ⚙️ Key Technical Details

### Process Matching
Uses the specific main class name (`com.threerings.yohoho.client.YoApp`) instead of generic matching like "java.exe". This ensures:
- No false positives from other Java applications
- Reliable identification even with multiple Java processes running

### Non-Intrusive Inspection
All inspection is done via `jcmd` queries, which:
- Don't modify the running JVM
- Don't pause or interrupt the game
- Return real-time information from the live process

### Bundled JDK
Uses the local `gizmo-jdk` folder instead of system Java, ensuring:
- Correct version is always used
- Works even if system Java is broken or missing
- Consistent behavior across user machines

## 📌 Usage

```batch
check-game-java.bat
```

Simply run the script while YPP is running. It will:
1. Locate the running game client
2. Display all diagnostic information
3. Highlight whether critical flags are present
4. Pause for you to review the output

### Common Issues & Solutions

**"No Puzzle Pirates client found"**
- Make sure the game is running
- The game must be fully loaded (not just the launcher)
- Click "Play" to enter the game

**"EnableDynamicAgentLoading" is missing or false**
- The game client wasn't started with the required flag
- Manual fix: Add `-XX:+EnableDynamicAgentLoading` to game launch settings
- Contact game support if unsure how to add JVM flags

## 🎓 Key Learnings

1. **JVM Process Management** - How to reliably discover and inspect running Java processes using `jps` and `jcmd`
2. **Diagnostic Tool Design** - Creating user-friendly diagnostic scripts that gather and present complex system information
3. **Flag Validation** - Understanding which JVM flags are critical for specific use cases (in this case, dynamic instrumentation and Java Agent loading)
4. **Cross-Platform Installation Challenges** - Why process discovery via JVM internals is more reliable than filesystem path guessing
5. **User Support** - Building tools that empower non-technical users to self-diagnose issues

## 🚀 Evolution & Legacy Status

This script was crucial during the initial Java 25 migration when users needed quick diagnostics. It helped answer critical questions:
- "Is my Java version correct?"
- "Is the critical flag set?"
- "Where is my installation?"

Modern YPP-Gizmo implementations handle most of this automatically through better initialization and flag management. However, this script remains valuable as:
- A **diagnostic tool** for troubleshooting
- A **demonstration** of JVM introspection capabilities
- A **reference** for understanding the Java Agent setup process

## 📁 Related Scripts

- **[jlink.bat](../jlink/)** - Prepares the custom JRE that this diagnostic validates
- **[attach.bat](../attach/)** - Uses the PID and flag information from this diagnostic to attach Java Agents

---

**Created:** Early 2025 (during YPP Java 25 migration)
**Status:** Stable, no longer required for operation, but useful for diagnostics
**Language:** Batch (Windows Command Script)
