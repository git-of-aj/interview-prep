Exactly. You’ve just hit one of the **most important mental models in Python**.

 And your question is precisely the right one:

 > **When do two variables point to the same object, and when does Python create/reassign an object?**

 The key is to distinguish **changing an object** from **changing what a variable points to**.

 ## 1\. `b = a` makes both names point to the same object

 Start here:

```
a = [1, 2, 3]
b = a
```

 Think of Python's memory roughly like this:

```
        ┌───────────────┐
a ─────→│               │
        │  [1, 2, 3]    │
b ─────→│               │
        └───────────────┘
```

 There is **one list** and two names pointing at it.

 So:

```
a is b
```

 gives:

```
True
```

---

 # 2\. `b.append(4)` modifies the object

 Now:

```
b.append(4)
```

 You're modifying the existing list.

```
        ┌────────────────┐
a ─────→│                │
        │ [1, 2, 3, 4]   │
b ─────→│                │
        └────────────────┘
```

 Since `a` and `b` point to that same list, both observe the modification.

```
print(a)  # [1, 2, 3, 4]
print(b)  # [1, 2, 3, 4]
```

---

 # 3\. But `a = [10, 20, 30]` does NOT modify the old list

 This is the part that caused your surprise.

 Starting:

```
a = [1, 2, 3]
b = a
```

 we have:

```
        ┌─────────────┐
a ─────→│ [1, 2, 3]   │
b ─────→│             │
        └─────────────┘
```

 Then you execute:

```
a = [10, 20, 30]
```

 Python creates a **new list** and makes `a` point to it:

```
        ┌───────────────┐
a ─────→│ [10, 20, 30]  │
        └───────────────┘

        ┌─────────────┐
b ─────→│ [1, 2, 3]   │
        └─────────────┘
```

 Notice what happened:

 **You didn't modify `[1, 2, 3]`.**

 You changed the thing that the **name `a` refers to**.

 `b` is still pointing to the original list.

 Therefore:

```
print(a)
# [10, 20, 30]

print(b)
# [1, 2, 3]
```

---

 # This distinction is EVERYTHING

 Compare:

 ### Mutating an object

```
b.append(4)
```

 vs.

 ### Reassigning a variable

```
a = [10, 20, 30]
```

 They're fundamentally different.

 | Code | What happens? |
| --- | --- |
| `b.append(4)` | Modify existing list |
| `b[0] = 100` | Modify existing list |
| `b.extend([5,6])` | Modify existing list |
| `a = [10,20,30]` | Make `a` point to a new list |
| `a = b` | Make `a` point to whatever `b` points to |

A good mental rule:

 > **Methods like `append()` mutate the object. Assignment changes the reference.**

---

 # Let's prove it

 Run this:

```
a = [1, 2, 3]
b = a

print(a is b)

b.append(4)

print(a is b)

a = [10, 20, 30]

print(a is b)
```

 You'll get:

```
True
True
False
```

 Why?

 Initially:

```
a ──┐
    ↓
 [1,2,3]
    ↑
b ──┘
```

 After `b.append(4)`:

```
a ──┐
    ↓
 [1,2,3,4]
    ↑
b ──┘
```

 After `a = [10,20,30]`:

```
a ──→ [10,20,30]

b ──→ [1,2,3,4]
```

 Now they're separate.

---

 # So when does Python create a new object?

 This is where we need to be slightly careful.

 When you write:

```
a = [1, 2, 3]
```

 Python evaluates the right-hand side:

```
[1, 2, 3]
```

 That creates a list object, and then `a` is bound to it.

 If you subsequently do:

```
a = [10, 20, 30]
```

 the new list is created and `a` is rebound to it.

 Python doesn't look at `b` and say:

 > "Hey, `a` and `b` were sharing this list, so I should update both."

 There is no such rule.

 Python simply performs the assignment.

---

 # Now there's an important twist

 Consider:

```
a = [1, 2, 3]
b = a

a += [4]
```

 What do you think happens?

 This is a fantastic example because `+=` can involve **mutation rather than simple reassignment**, depending on the type.

 For a list, `a += [4]` effectively mutates the existing list.

 So you'd expect:

```
print(a)
print(b)
```

 to be:

```
[1, 2, 3, 4]
[1, 2, 3, 4]
```

 This is one reason Python's distinction between **mutable objects and immutable objects** is so important.

---

 # And now we can explain `int` vs `list`

 Consider:

```
a = 10
b = a

a = 20

print(a)
print(b)
```

 You get:

```
20
10
```

 This looks similar to our list example.

 But integers are **immutable**.

 You can't do:

```
a.change_my_value_to(20)
```

 to mutate the integer `10`.

 Instead:

```
a = 20
```

 makes `a` refer to another integer object/value.

 Compare that with:

```
a = [1, 2, 3]
b = a

a.append(4)
```

 The list itself can be modified.

---

 # The mental model I want you to build

 Don't think:

```
a = value
```

 Think:

```
             object
               ↑
               |
              name
```

 For example:

```
a = [1, 2, 3]
```

 means approximately:

```
a ─────→ [1, 2, 3]
```

 Then:

```
b = a
```

 means:

```
a ─────→ [1, 2, 3] ←───── b
```

 Then:

```
a = [10, 20, 30]
```

 means:

```
a ─────→ [10, 20, 30]

b ─────→ [1, 2, 3]
```

 Whereas:

```
a.append(4)
```

 means:

```
a ─────→ [1, 2, 3, 4]
              ↑
b ────────────┘
```

 **That is the model I want you to internalize.**

---

 ## One final challenge before we move on

 Predict all four outputs **without running the code**:

```
a = [1, 2, 3]
b = a

b.append(4)

print(a)
print(b)

a = [10, 20, 30]

print(a)
print(b)
```

 And then answer this in your own words:

 > **What is the difference between mutating an object and reassigning a variable?**

 Once you've got that, we'll go into `is` vs `==`, `id()`, shallow/deep copies, and then function arguments — where this exact concept becomes _very_ important for AI SDE interviews.
