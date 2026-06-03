# portrait_scrape.py

## 📋 Overview

A resilient web scraper that enumerates Yahoo Puzzle Pirates portrait gallery IDs to discover unreleased or hidden content. This script demonstrates robust data collection patterns including rate limiting, error recovery, VPN integration, and persistent state management.

## 🎯 Problem Statement

Yahoo Puzzle Pirates periodically adds new player portrait artwork to their gallery. However, these additions aren't always announced, and the gallery IDs are sequential. This creates an opportunity for discovery:

- **Hidden Content** - New portraits might be added but not publicly announced
- **Preview Access** - Developers sometimes place portraits before official release
- **Compliance Items** - Certain portrait additions are made for regulatory reasons
- **Manual Discovery** - Manually checking hundreds of portrait IDs is impractical
- **Rate Limiting** - The server blocks aggressive scraping with rate limits and IP bans

The challenge is to efficiently enumerate portrait IDs while respecting server resources and avoiding being blocked.

## 💡 Solution

This script implements a resilient scraper with sophisticated rate limiting and recovery:

1. **Configurable Range** - Define start/end portrait ID ranges
2. **Intelligent Throttling** - Adaptive delays between requests (1.5 seconds default)
3. **Error Detection** - Recognizes deletion/404 responses from server
4. **VPN Integration** - Optional VPN monitoring to detect connection loss
5. **Fail-Safe Limits** - Stops after N consecutive failures (prevents infinite loops)
6. **Session Persistence** - Maintains list of valid portrait IDs found
7. **Progress Reporting** - Real-time feedback on success rate and discoveries

## 🔧 How It Works

### Core Loop

```python
while len(numbers) > 0:
    # Throttle requests
    sleep_time = delay - time.time() + last_time
    if sleep_time > 0:
        time.sleep(sleep_time)
    last_time = time.time()
    
    # VPN check (optional)
    # Try to fetch portrait
    # Track success/failure
```

The main loop:
- Processes portrait IDs sequentially
- Enforces timing between requests
- Catches errors and retries
- Stops after too many consecutive failures

### Rate Limiting Strategy

```python
last_time = time.time()
delay = 1.5  # seconds between requests
```

**Configuration:**
- **`delay = 1.5`** - Wait 1.5 seconds minimum between requests
- **`fail_allowance = 19`** - Allow 19 consecutive failures before stopping

**Why 1.5 seconds?**
- Respectful of server resources
- Avoids aggressive rate-limit triggers
- Allows for ~2400 requests per hour
- Practical for discovery sessions (few hours)

### Content Detection

```python
deleted_message = "Shiver me timbers: Some horrible daemons have prevented us from processing yer request..."

if not deleted_message in page:
    portraits_found += 1
    valid_id.append(numbers[0])
```

**How it works:**
- The server returns this specific error message for deleted/invalid portraits
- If the message is NOT present, the portrait exists
- Stores valid portrait IDs for reporting

### Error Recovery

```python
except urllib.error.URLError as e:
    print(e.reason)
    fails += 1
    
    if fails > fail_allowance:
        print(f"Stopping after {fail_allowance+1} consecutive blocks")
        quit()
    
    continue  # Retry the same ID
```

**Recovery strategy:**
- Catches network errors (timeouts, connection resets, etc.)
- Retries the same portrait ID
- Gives up after 20 consecutive failures
- This prevents infinite loops if the server goes offline

### VPN Monitoring (Optional)

```python
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.connect(("8.8.8.8", 80))

#if s.getsockname()[0] == "10.2.0.2":
#    print(f"VPN Broke: {s.getsockname()[0]}, saving and quitting at id: {numbers[0]}")
#    quit()
```

**What it does:**
- Creates a dummy socket to discover local IP
- Checks if connected through VPN (IP in VPN range like 10.x.x.x)
- If commented out: VPN monitoring disabled
- If enabled: Detects VPN disconnection and gracefully exits

**Why this matters:**
- Some rate-limit blocks are IP-specific
- If VPN drops, you'd start hitting blocks with your real IP
- Better to stop than to get your real IP blocked

## 📊 Configuration Guide

```python
start_id = 2664684      # Your latest portrait ID
final_id = 2661626     # Oldest portrait you know about
amount = 2000          # Maximum IDs to scan
```

### How to Configure

1. **Find your latest portrait ID**
   - Go to your profile on puzzlepirates.com
   - Check your current portrait
   - Note the portrait ID from the URL
   - Set this as `start_id`

2. **Determine the range**
   - Decide how far back to scan (e.g., 2000 IDs)
   - Set `amount = 2000`
   - OR manually set `final_id = <oldest known ID>`
   - Script uses whichever is more conservative

3. **Adjust delays if needed**
   - Increase `delay` if getting rate-limited
   - Decrease `delay` if service permits (use caution)
   - Default 1.5 seconds is well-tested and respectful

4. **Optional: Enable VPN checking**
   - Uncomment the VPN check section
   - Set `"10.2.0.2"` to your VPN's expected IP range
   - Provides automatic safety kill-switch

## 📊 Output & Logging

### Console Output

```
2664684 scanned, success_rate = [150, 2], portraits_found = 3, portrait_IDs = [2664684, 2664681, 2664678]
2664683 scanned, success_rate = [151, 2], portraits_found = 3, portrait_IDs = [2664684, 2664681, 2664678]
```

**Metrics explained:**
- **First number** - Portrait ID being scanned
- **success_rate[0]** - Successful HTTP requests
- **success_rate[1]** - Failed HTTP requests
- **portraits_found** - Number of valid portraits discovered
- **portrait_IDs** - List of all valid portrait IDs found

### Final Output

```
valid_id = [2664684, 2664681, 2664678]
Finished
```

**Interpretation:**
- These portrait IDs exist on the server
- Could be unreleased content, special items, or developer previews

## 🛠️ Prerequisites & Setup

### System Requirements
- Python 3.6+
- Internet connection
- Optional: VPN software (for VPN checking to work)

### Python Modules (Standard Library)
```python
import urllib.request   # HTTP requests
import time           # Timing/delays
import socket         # Network socket operations
```

All modules are built-in; no pip install needed.

### Running the Script

```bash
python portrait_scrape.py
```

or

```bash
python3 portrait_scrape.py
```

## ⚙️ Key Technical Details

### Rate Limiting Math

```python
sleep_time = delay - time.time() + last_time
if sleep_time > 0:
    time.sleep(sleep_time)
```

**How it works:**
- Records time of last request (`last_time`)
- On next iteration, calculates how much time has passed
- If less than `delay` seconds have passed, sleeps for the remainder
- Guarantees at least `delay` seconds between requests

**Example:**
- Request at 00:00:00
- Next iteration at 00:00:00.5
- `sleep_time = 1.5 - 0.5 = 1.0`
- Sleep for 1.0 seconds
- Resume at 00:00:01.5 (exactly 1.5 seconds later)

### Error Detection

Server response for missing portrait:
```html
<html>
<body>
Shiver me timbers: Some horrible daemons have prevented us from processing yer request. 
Please check to make sure that the message you typed is not too long, and try again.
</body>
</html>
```

This exact text indicates:
- The portrait ID does not exist
- OR the server blocked the request
- The script treats both as "portrait not found"

### Fault Tolerance

```python
fail_allowance = 19  # Stop after 20 consecutive failures
```

**Scenarios this handles:**
- **Brief network hiccup** - Retries automatically
- **Rate limit block** - Waits and retries; might succeed after delay
- **Server goes down** - Exits gracefully after 20 failures
- **Wrong VPN IP** - Can detect and exit cleanly

## 📌 Usage Patterns

### Basic Discovery

```bash
python portrait_scrape.py
```

Scans from your latest portrait ID back 2000 IDs, finds new content.

### Targeted Range

Modify the script:
```python
start_id = 2665000     # Start here
final_id = 2664500     # End here
amount = 99999         # Ignore this (range is more specific)
```

Scans precisely the 500-ID range specified.

### With VPN Safety

1. Edit script to uncomment VPN check
2. Update the IP address to your VPN's range
3. Run normally
4. Script auto-stops if VPN disconnects

### Resuming Failed Runs

If the script exits early:
1. Note the last ID printed
2. Set `start_id` to that ID
3. Run again
4. Results accumulate in `valid_id` list

## 🎓 Key Learnings

1. **Rate Limiting** - How to implement client-side throttling that respects server resources
2. **Error Recovery** - Designing robust retry logic with fail-safes
3. **Content Detection** - Recognizing server-side error messages vs. valid responses
4. **Network Programming** - Using Python's socket module for network operations
5. **State Management** - Tracking and persisting discovery state across failures
6. **VPN Integration** - Monitoring and reacting to VPN connection changes
7. **User Experience** - Providing real-time feedback and graceful failure modes

## 🚀 Evolution & Legacy Status

### Historical Context

This script was part of the YPP community's exploratory data collection:
- Discovered upcoming content before announcements
- Found hidden or developer-preview content
- Demonstrated both technical capability and community engagement

### Compliance & Ethics

- **Rate limiting** - Respects server resources (1.5s delay)
- **Terms of service** - Check YPP's ToS regarding scraping (this is for personal discovery)
- **VPN option** - Provides privacy for users concerned about tracking
- **Data use** - Results are typically shared within the community for fun

### Current Status

- **Still functional** - Portrait gallery structure hasn't changed
- **Not required** - Official announcements cover most new content now
- **Demonstrates** - Robust error handling and resilient data collection patterns

## 📚 References

- [Python urllib Documentation](https://docs.python.org/3/library/urllib.html)
- [Python socket Documentation](https://docs.python.org/3/library/socket.html)
- [HTTP Rate Limiting Best Practices](https://developer.mozilla.org/en-US/docs/Glossary/rate_limit)

## 🔐 Privacy & Security Notes

- **No authentication**: Script never logs into YPP (read-only)
- **Public data**: Only accesses publicly available portrait gallery
- **VPN optional**: Built-in VPN monitoring is optional
- **Local-only**: Results stay on your machine (script doesn't upload)

---

**Created:** 2024-2025 (YPP community data exploration)
**Status:** Functional, no longer actively maintained
**Language:** Python 3.6+
**Key Capabilities:** Resilient web scraping, rate limiting, error recovery, VPN integration
