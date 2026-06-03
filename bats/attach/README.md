# attach.bat

## 📋 Overview

A straightforward Java Agent attachment utility that dynamically loads YPP-Gizmo into a running Yahoo Puzzle Pirates game client. This script provides the critical bridge between YPP-Gizmo and the game JVM, enabling real-time instrumentation and third-party tool functionality.

## 🎯 Problem Statement

After the Java 8 → Java 25 migration, YPP-Gizmo faced a fundamental challenge:

- **Broken Accessibility Bridge**: The Java Accessibility Bridge approach no longer worked with Java 25
- **Runtime Attachment Required**: YPP-Gizmo needed to attach to an already-running game process
- **User Friction**: Users had to manually attach the tool after launching the game
- **Process Discovery**: Finding the correct game JVM among potentially multiple Java processes
- **Error-Prone Manual Steps**: Users were making mistakes in the attachment process

This script automates the entire attachment workflow, reducing errors and improving user experience.

## 💡 Solution

The script handles the complete Java Agent attachment cycle:

1. **Dependency Validation** - Ensures all required files exist (jdk, jcmd, agent jar)
2. **Process Discovery** - Finds the running YPP client JVM using `jps`
3. **Error Handling** - Validates process discovery and provides clear error messages
4. **Agent Loading** - Uses `jcmd` to dynamically load the Gizmo.jar agent
5. **Status Reporting** - Confirms success or explains failures

## 🔧 How It Works

### Setup Phase

```batch
set "JDK=%~dp0gizmo-jdk"
set "JPS=%JDK%\bin\jps.exe"
set "JCMD=%JDK%\bin\jcmd.exe"
set "AGENT=%~dp0Gizmo.jar"
```

Paths are resolved relative to the script location (`%~dp0`), ensuring portability.

### Dependency Validation

```batch
for %%T in ("%JPS%" "%JCMD%" "%AGENT%") do if not exist "%%~T" (
  echo Missing: %%~T
  pause & exit /b 1
)
```

Checks that all required files exist before attempting attachment. Fails fast with clear error messages.

### Process Discovery

```batch
echo Looking for Puzzle Pirates client...
for /f "tokens=1" %%P in (
  '"%JPS%" -l ^| findstr /i yohoho'
) do set PID=%%P
```

- **`jps -l`** - Lists all running Java processes with full class names
- **`findstr /i yohoho`** - Filters for processes containing "yohoho" (case-insensitive)
- **`tokens=1`** - Extracts just the Process ID

This approach:
- Works without registry queries or hardcoded installation paths
- Tolerates variations in package names and configurations
- Finds the process in seconds

### Agent Attachment

```batch
echo Attaching Gizmo to PID %PID% ...
"%JCMD%" %PID% JVMTI.agent_load "%AGENT%" 2>&1
```

**How it works:**
- **`JVMTI.agent_load`** - JVM Tool Interface command to dynamically load an agent
- **`%AGENT%`** - Path to the Gizmo.jar agent library
- **`2>&1`** - Redirects error output to standard output for visibility

**Requirements (from JVM perspective):**
- JVM must be running with `-XX:+EnableDynamicAgentLoading` flag
- The agent JAR must be a valid JVMTI agent with proper manifest
- The JVM must have `java.instrument` module available

### Status Reporting

```batch
if %errorlevel%==0 (
  echo SUCCESS - Gizmo window will appear if already logged in.
) else (
  echo Attach failed - ensure game was started with -XX:+EnableDynamicAgentLoading
)
```

Provides actionable feedback:
- **Success**: Explains what to expect next
- **Failure**: Hints at the most common cause (missing JVM flag)

## 📊 Output Example

### Success Case

```
Looking for Puzzle Pirates client...
Found client with PID: 8492

Attaching Gizmo to PID 8492 ...
Command executed successfully.

SUCCESS - Gizmo window will appear if already logged in.
```

### Failure Cases

**Missing file:**
```
Missing: C:\path\to\Gizmo.jar
```

**Game not running:**
```
Looking for Puzzle Pirates client...
No Puzzle Pirates client found.
Please start the game and log in first.
```

**JVM flag missing:**
```
Attaching Gizmo to PID 8492 ...
Attach failed - enable dynamic agent loading not enabled

Attach failed - ensure game was started with -XX:+EnableDynamicAgentLoading
```

## 🛠️ Prerequisites

### Required Files
- **gizmo-jdk** - Bundled Java 25.0.1 with java.instrument support
- **Gizmo.jar** - The YPP-Gizmo agent library
- **attach.bat** - This script

### System Requirements
- Windows system with Command Prompt
- Yahoo Puzzle Pirates game installed and running
- Game must be fully logged in (for Gizmo functionality)

### JVM Requirements (at game startup)
- Java 25.0.1+
- `-XX:+EnableDynamicAgentLoading` flag enabled
- `java.instrument` module available (provided by custom JRE from jlink.bat)

## ⚙️ Key Technical Details

### Process Matching Strategy

```batch
findstr /i yohoho
```

Why this works:
- Matches any class name containing "yohoho" (the game package domain)
- Case-insensitive (`/i` flag) handles different configurations
- Simple enough to be reliable across setups
- Specific enough to avoid false positives from other games or applications

### JVMTI Agent Loading

The `JVMTI.agent_load` command:
- Invokes the JVM Instrumentation API
- Requires the agent JAR to have proper `Agent-Class` manifest entry
- Works on already-running JVMs (no restart needed)
- Bypasses the need for startup-time agent configuration

### Error Handling Philosophy

- **Fail fast**: Validates prerequisites before attempting attachment
- **Clear errors**: Each failure mode has a specific message
- **Actionable hints**: Error messages suggest fixes
- **Pause for review**: Waits for user to read the output

## 📌 Usage

```batch
attach.bat
```

### Before Running

1. **Launch YPP**
   - Start the game client
   - Log in to your account
   - Wait for the game to fully load

2. **Run the script**
   ```batch
   cd C:\path\to\gizmo-tools
   attach.bat
   ```

3. **Check results**
   - If successful: YPP-Gizmo overlay will appear
   - If failed: Follow the error message suggestions

### Timing Considerations

- **Best time**: While game is running and logged in
- **Early attachment**: Can attach at any point after game launch
- **Session persistence**: Agent remains loaded until game closes
- **Multi-attachment**: Safe to run multiple times (second run will fail gracefully)

## 🎓 Key Learnings

1. **Java Process Management** - Using jps/jcmd for process discovery and manipulation
2. **Dynamic Instrumentation** - Understanding how Java Agents attach to running JVMs
3. **Error Handling** - Designing scripts that fail gracefully with helpful messages
4. **User Experience** - Automating complex JVM operations for non-technical users
5. **JVMTI/JVM Internals** - How the Java Instrumentation API enables runtime code modification

## 🚀 Evolution & Legacy Status

### Historical Purpose

This script was a **critical interim solution** during the Java 25 migration:
- Provided a quick way to get YPP-Gizmo working again
- Reduced support load by automating the attachment process
- Validated that the Java Agent approach was viable

### Why It's No Longer Needed

Later developments made manual attachment unnecessary:
- **Automatic startup attachment**: YPP-Gizmo evolved to attach at game launch
- **Agent auto-discovery**: The tool learned to find itself without manual commands
- **Better JVM integration**: Game developers integrated better flag management

However, the script demonstrates:
- Deep understanding of JVM internals
- Practical problem-solving under constraints
- User-centric automation design
- Effective troubleshooting workflows

## 📁 Related Scripts

- **[check-game-java.bat](../check-game-java/)** - Pre-flight check that validates the JVM state
- **[jlink.bat](../jlink/)** - Prepares the custom JRE with java.instrument support

## 📚 References

- [Java Instrumentation API](https://docs.oracle.com/javase/25/docs/api/java.instrument/java/lang/instrument/package-summary.html)
- [JVMTI Reference](https://docs.oracle.com/javase/25/docs/specs/jvmti.html)
- [jcmd Tool Documentation](https://docs.oracle.com/en/java/javase/25/docs/specs/man/jcmd.html)

---

**Created:** Early 2025 (during YPP Java 25 migration)
**Status:** Stable, no longer required but demonstrates Java instrumentation expertise
**Language:** Batch (Windows Command Script)
**Key Dependency:** Java 25.0.1 with dynamic agent loading support
