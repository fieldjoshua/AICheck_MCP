# AICheck Quick Start - 5 Essential Commands

## 📋 The Only Commands You Need

```bash
./aicheck stuck           # What's happening? Get help
./aicheck deploy-check    # Ready to deploy? Check first!
./aicheck action new      # Create a new action (task/feature)
./aicheck action set      # Set the ACTIVE action (switch context)
./aicheck action complete # Complete the ACTIVE action
```

## 🔍 Understanding Actions vs ACTIVE Action

- **Action**: A task, feature, or unit of work (e.g., "FixLoginBug", "AddUserAuth")
- **ACTIVE Action**: The currently selected action that all your work is tracked under
- You can have many actions, but only ONE can be ACTIVE at a time

## 🚀 Common Scenarios

### Starting a New Feature
```bash
./aicheck action new AddUserLogin    # Creates the action
./aicheck action set AddUserLogin    # Makes it the ACTIVE action
# ... work on code ...
./aicheck deploy-check
git push
./aicheck action complete            # Completes the ACTIVE action
```

### Feeling Lost?
```bash
./aicheck stuck   # Shows status and suggests fixes
```

### Before Deploying
```bash
./aicheck deploy-check   # Checks everything:
                        # - Dependencies locked?
                        # - Tests passing?
                        # - Git clean?
```

## 🤖 What Happens Automatically

- **Session starts**: Status check runs
- **Before push**: Tests run, dependencies checked
- **After commits**: Compliance verification
- **Context grows**: Auto-cleanup suggestions
- **Scope creep**: Boundary warnings

You don't need to run these manually - AICheck handles them!

## 💡 Pro Tips

1. **Stuck?** Always run `./aicheck stuck` first
2. **Deploying?** Always run `./aicheck deploy-check` first
3. **Dependencies?** Just use `poetry add` or `npm install` - AICheck tracks them

---

That's it! Just 5 commands. Everything else is automatic.