# AICheck Quick Guide - When to Use What

## 🚀 **Most Common Situations**

### 😵 **"I'm confused / lost / don't know what's happening"**
```bash
./aicheck stuck
```
**What it does:** Shows your current status + gives you quick fixes to try

---

### 🎯 **"Am I working on the right thing? Did I drift off track?"**
```bash
./aicheck focus
```
**What it does:** Checks if you're staying within your action boundaries, detects scope creep

---

### 🗂️ **"Too many files, things feel cluttered"**
```bash
./aicheck cleanup
```
**What it does:** Cleans up old logs, creates summaries, optimizes context for better performance

---

### 📊 **"Am I using too much Claude Code? Worried about costs?"**
```bash
./aicheck usage
```
**What it does:** Shows usage patterns, thinking intensity, gives optimization tips

---

### 🧹 **"Everything feels broken, I need a fresh start"**
```bash
./aicheck reset
```
**What it does:** Cleans up pollution, archives old stuff (asks permission for destructive actions)

---

## 📋 **Core Workflow Commands**

### 🆕 **Starting New Work**
```bash
./aicheck action new MyFeatureName    # Create a new action
./aicheck action set MyFeatureName    # Make it active
```

### 📈 **Checking Progress**
```bash
./aicheck status                      # See current action + context health
```

### ✅ **Finishing Work**
```bash
./aicheck action complete             # Mark current action as done
```

---

## 💡 **Pro Tips**

- **Start with `./aicheck stuck`** if you're ever unsure
- **Use `./aicheck focus`** before big changes to make sure you're on track
- **Run `./aicheck cleanup`** when files get unwieldy  
- **Check `./aicheck usage`** if Claude Code feels slow or expensive
- **Templates in `.aicheck/templates/claude/`** have proven patterns for common tasks

---

## 🔄 **Typical Development Flow**

1. **Start:** `./aicheck action new FixLoginBug`
2. **Set active:** `./aicheck action set FixLoginBug`  
3. **Check focus:** `./aicheck focus` (before making changes)
4. **Work on code...**
5. **Check progress:** `./aicheck status`
6. **Clean up:** `./aicheck cleanup` (if things get messy)
7. **Finish:** `./aicheck action complete`

**The key insight:** Use the simple commands (`stuck`, `focus`, `cleanup`, `usage`, `reset`) instead of trying to remember complex context management syntax!