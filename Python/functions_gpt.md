Absolutely. This is the next major Python layer. And we'll connect everything back to the **reference/mutability model** you just learned.

 # Lesson 3 — Functions, Scope, LEGB, `*args`, `**kwargs`

 For an AI SDE role, you want to be comfortable reading code like:

```
def process_documents(
    documents,
    model="gpt",
    *,
    batch_size=32,
    **options
):
    ...
```

 without having to stop and decode what the syntax means.

 We'll build up to that.

---

 # 1\. Functions are objects too

 Start with the basic syntax:

```
def greet(name):
    return f"Hello, {name}"
```

 Calling it:

```
message = greet("Alice")

print(message)
```

 Output:

```
Hello, Alice
```

 The basic structure is:

```
def function_name(parameters):
    # body
    return result
```

 A key distinction:

```
greet
```

 refers to the function object.

```
greet("Alice")
```

 **calls** the function.

 This distinction becomes important later with decorators.

---

 # 2\. Parameters vs arguments

 Consider:

```
def add(a, b):
    return a + b
```

 Here:

```
a, b
```

 are **parameters**.

 When we call:

```
add(10, 20)
```

 then:

```
10, 20
```

 are **arguments**.

 You'll often hear people casually use the terms interchangeably, but technically this distinction is useful.

---

 # 3\. Python passes object references

 Now connect this to what you learned earlier.

 Consider:

```
def add_item(items):
    items.append("Python")

models = ["GPT", "Claude"]

add_item(models)

print(models)
```

 Result:

```
['GPT', 'Claude', 'Python']
```

 Why?

 Before the function call:

```
models ─────→ ["GPT", "Claude"]
```

 When calling:

```
add_item(models)
```

 the parameter `items` becomes another reference to the same list:

```
models ─────┐
            ↓
       ["GPT", "Claude"]
            ↑
items ──────┘
```

 Then:

```
items.append("Python")
```

 mutates the shared list.

 So `models` sees the change.

---

 # 4\. But reassignment behaves differently

 Consider:

```
def replace_items(items):
    items = ["Python", "Java"]

models = ["GPT", "Claude"]

replace_items(models)

print(models)
```

 What happens?

```
['GPT', 'Claude']
```

 Why?

 Initially:

```
models ─────→ ["GPT", "Claude"]
```

 Inside the function:

```
items = ["Python", "Java"]
```

 creates a new list and makes the **local name** `items` point to it:

```
models ─────→ ["GPT", "Claude"]

items ─────→ ["Python", "Java"]
```

 When the function ends, the local `items` reference disappears.

 `models` was never changed.

 This is exactly the reference/mutation distinction from our previous lesson.

---

 # 5\. The famous mutable-default-argument trap

 This is one of the most important Python interview questions.

 Look at:

```
def add_model(model, models=[]):
    models.append(model)
    return models
```

 Now:

```
print(add_model("GPT"))
print(add_model("Claude"))
print(add_model("Gemini"))
```

 Many beginners expect:

```
['GPT']
['Claude']
['Gemini']
```

 But you get:

```
['GPT']
['GPT', 'Claude']
['GPT', 'Claude', 'Gemini']
```

 Why?

 Because the default list:

```
models=[]
```

 is created **once**, when the function is defined, not every time the function is called.

 So all calls share that same list.

 ### Correct pattern

 Use `None`:

```
def add_model(model, models=None):
    if models is None:
        models = []

    models.append(model)
    return models
```

 Now each call gets a fresh list.

 This is a classic Python interview topic.

---

 # 6\. Scope

 Now we get to **scope**.

 Consider:

```
x = 10

def foo():
    x = 20
    print(x)

foo()

print(x)
```

 Output:

```
20
10
```

 Why?

 There are two different variables/names called `x`.

```
GLOBAL SCOPE

x → 10

foo's LOCAL SCOPE

x → 20
```

 The local `x` doesn't replace the global `x`.

 This is where **LEGB** comes in.

---

 # 7\. LEGB

 Python searches for a variable according to this order:

```
L → Local
E → Enclosing
G → Global
B → Built-in
```

 Hence:

 # LEGB

 Let's understand each.

---

 ## L — Local

```
def process():
    model = "GPT"
    print(model)
```

 `model` exists in the local scope of `process`.

 After the function finishes, you can't normally access it:

```
print(model)
```

 would raise:

```
NameError
```

---

 # E — Enclosing

 This occurs with nested functions.

```
def outer():
    model = "GPT"

    def inner():
        print(model)

    inner()

outer()
```

 `inner()` doesn't have a local `model`.

 Python searches outward and finds:

```
inner local
   ↓
outer local
   ↓
global
   ↓
built-ins
```

 It finds `model` in `outer`.

 That's the **E** in LEGB.

---

 # G — Global

```
model = "GPT"

def show_model():
    print(model)

show_model()
```

 `show_model()` doesn't have a local `model`.

 There isn't an enclosing function either.

 So Python eventually searches the global scope.

 It finds:

```
model = "GPT"
```

---

 # B — Built-in

 Suppose you write:

```
print(len([1, 2, 3]))
```

 Where does Python find `len`?

 Not locally.

 Not in an enclosing function.

 Not necessarily in your module's global variables.

 It finds `len` in Python's **built-in namespace**.

 Other built-ins include:

```
print()
len()
sum()
min()
max()
range()
enumerate()
zip()
sorted()
isinstance()
type()
id()
```

---

 # 8\. LEGB in action

 Consider:

```
x = "global"

def outer():
    x = "enclosing"

    def inner():
        x = "local"
        print(x)

    inner()

outer()
```

 Output:

```
local
```

 Because the first matching `x` is local.

 Remove the inner assignment:

```
x = "global"

def outer():
    x = "enclosing"

    def inner():
        print(x)

    inner()

outer()
```

 Now:

```
enclosing
```

 Remove the outer assignment too:

```
x = "global"

def outer():

    def inner():
        print(x)

    inner()

outer()
```

 Now:

```
global
```

 And if there were no `x` anywhere:

 Python eventually searches built-ins.

---

 # 9\. `global`

 Here's a common surprise.

```
counter = 0

def increment():
    counter += 1
```

 This doesn't work.

 You'll get an `UnboundLocalError`.

 Why?

 Because Python sees:

```
counter += 1
```

 as an assignment to `counter`.

 Therefore Python treats `counter` as a **local variable** inside `increment`.

 But you're trying to read it before that local variable has a value.

 You can explicitly tell Python:

```
counter = 0

def increment():
    global counter
    counter += 1
```

 Now it works.

 But in production code, excessive use of `global` is generally a smell. Passing state explicitly or encapsulating it in an object is usually easier to reason about.

---

 # 10\. `nonlocal`

 `nonlocal` is related, but applies to **enclosing function scope**.

 Example:

```
def counter():
    count = 0

    def increment():
        nonlocal count
        count += 1
        return count

    return increment
```

 Then:

```
c = counter()

print(c())
print(c())
print(c())
```

 Output:

```
1
2
3
```

 What's happening?

 `increment()` remembers the `count` from `counter()`.

 This is a **closure**.

 We'll study closures more deeply when we get to decorators.

---

 # 11\. `*args`

 Now let's tackle one of the most recognizable Python patterns.

 Suppose:

```
def add(a, b):
    return a + b
```

 It requires exactly two arguments.

 But what if you want arbitrary positional arguments?

```
def add(*args):
    return sum(args)
```

 Now:

```
print(add(1, 2))
print(add(1, 2, 3))
print(add(1, 2, 3, 4, 5))
```

 works.

 Inside the function:

```
args
```

 is a **tuple**.

 For example:

```
def inspect(*args):
    print(args)
    print(type(args))

inspect(10, "hello", True)
```

 Output conceptually:

```
(10, 'hello', True)
<class 'tuple'>
```

 Important:

 > `*args` doesn't mean "args is magically special."

 It means:

 > Collect additional positional arguments into a tuple.

 The name `args` itself isn't special.

 This works too:

```
def foo(*values):
    print(values)
```

---

 # 12\. Unpacking with `*`

 The same `*` also works in the opposite direction.

 Suppose:

```
numbers = [1, 2, 3]
```

 and:

```
def add(a, b, c):
    return a + b + c
```

 You can do:

```
add(*numbers)
```

 Python effectively turns it into:

```
add(1, 2, 3)
```

 So:

```
* in function definition
→ collect arguments

* in function call
→ unpack arguments
```

 That's a very useful pattern to remember.

---

 # 13\. `**kwargs`

 Now suppose we want arbitrary keyword arguments.

```
def configure_model(**kwargs):
    print(kwargs)
```

 Call:

```
configure_model(
    temperature=0.7,
    max_tokens=1000,
    streaming=True
)
```

 Inside the function:

```
kwargs
```

 is a **dictionary**:

```
{
    "temperature": 0.7,
    "max_tokens": 1000,
    "streaming": True
}
```

 Again, `kwargs` isn't a magical name.

 This is valid:

```
def configure_model(**options):
    print(options)
```

---

 # 14\. `**` also has an opposite operation

 Given:

```
config = {
    "temperature": 0.7,
    "max_tokens": 1000
}
```

 and:

```
def configure(temperature, max_tokens):
    print(temperature, max_tokens)
```

 You can do:

```
configure(**config)
```

 which is effectively:

```
configure(
    temperature=0.7,
    max_tokens=1000
)
```

 So:

```
*args
    positional arguments → tuple

**kwargs
    keyword arguments → dict
```

---

 # 15\. Combining everything

 Now here's a function you'll see frequently in real Python code:

```
def process(
    model,
    *documents,
    temperature=0.7,
    **options
):
    print(model)
    print(documents)
    print(temperature)
    print(options)
```

 Call:

```
process(
    "GPT",
    "doc1",
    "doc2",
    "doc3",
    temperature=0.2,
    streaming=True,
    timeout=30
)
```

 Inside:

```
model
→ "GPT"

documents
→ ("doc1", "doc2", "doc3")

temperature
→ 0.2

options
→ {
    "streaming": True,
    "timeout": 30
}
```

 This is very useful for building flexible APIs.

---

 # 16\. A very important syntax: keyword-only arguments

 Look at:

```
def generate(
    model,
    prompt,
    *,
    temperature=0.7,
    max_tokens=1000
):
    ...
```

 The `*` means:

 > Everything after this must be passed by keyword.

 This works:

```
generate(
    "GPT",
    "Explain Python",
    temperature=0.2,
    max_tokens=500
)
```

 But this doesn't:

```
generate(
    "GPT",
    "Explain Python",
    0.2,
    500
)
```

 Why is this useful?

 Because:

```
generate("GPT", "Explain Python", 0.2, 500)
```

 is less readable.

 Whereas:

```
generate(
    "GPT",
    "Explain Python",
    temperature=0.2,
    max_tokens=500
)
```

 makes the meaning obvious.

 You'll see keyword-only parameters frequently in good Python APIs.

---

 # 17\. AI SDE example

 Imagine we're building an LLM client:

```
def generate(
    prompt,
    *,
    model="gpt",
    temperature=0.7,
    max_tokens=1000
):
    ...
```

 Then:

```
generate(
    "Explain transformers",
    model="gpt",
    temperature=0.2,
    max_tokens=500
)
```

 This API is self-documenting.

 Now suppose we want extra provider-specific options:

```
def generate(
    prompt,
    *,
    model="gpt",
    temperature=0.7,
    **options
):
    print(prompt)
    print(model)
    print(temperature)
    print(options)
```

 Call:

```
generate(
    "Explain transformers",
    model="gpt",
    temperature=0.2,
    timeout=30,
    retries=3,
    stream=True
)
```

 Then:

```
options
```

 contains:

```
{
    "timeout": 30,
    "retries": 3,
    "stream": True
}
```

 This pattern is very relevant to AI infrastructure code.

---

 # 18\. One more important concept: functions can modify arguments

 Consider:

```
def update_config(config):
    config["temperature"] = 0.2

settings = {
    "temperature": 0.7
}

update_config(settings)

print(settings)
```

 Result:

```
{"temperature": 0.2}
```

 Because dictionaries are mutable.

 But:

```
def update_temperature(config):
    config = {
        "temperature": 0.2
    }

settings = {
    "temperature": 0.7
}

update_temperature(settings)

print(settings)
```

 still gives:

```
{"temperature": 0.7}
```

 Again:

```
mutation
    ↓
changes shared object

reassignment
    ↓
changes local reference
```

 This distinction will save you from a LOT of debugging headaches.

---

 # Hands-on exercises

 Don't just read these. **Write them and predict the outputs before running them.**

 ## Exercise 1 — Mutation

 What does this print?

```
def add_model(models):
    models.append("Gemini")

models = ["GPT", "Claude"]

add_model(models)

print(models)
```

 Explain using the reference model.

---

 ## Exercise 2 — Reassignment

 Now:

```
def add_model(models):
    models = models + ["Gemini"]

models = ["GPT", "Claude"]

add_model(models)

print(models)
```

 Why is this different?

 Pay particular attention to:

```
models = models + ["Gemini"]
```

 versus:

```
models.append("Gemini")
```

---

 ## Exercise 3 — `*args`

 Write:

```
def average(...):
    ...
```

 that accepts **any number of numbers**:

```
average(10, 20)
average(10, 20, 30)
average(1, 2, 3, 4, 5)
```

 and returns their average.

 Then print the type of the object containing the arguments.

---

 ## Exercise 4 — `**kwargs`

 Create:

```
def describe_model(...):
    ...
```

 such that:

```
describe_model(
    model="GPT",
    provider="OpenAI",
    context=128000,
    active=True
)
```

 prints something like:

```
model = GPT
provider = OpenAI
context = 128000
active = True
```

 You should **not hard-code the keys** inside the function.

 Use `**kwargs`.

---

 ## Exercise 5 — LEGB

 Predict the output:

```
x = "global"

def outer():
    x = "outer"

    def inner():
        x = "inner"
        print(x)

    inner()
    print(x)

outer()
print(x)
```

 Then change `inner()` to:

```
def inner():
    print(x)
```

 Predict the new output.

---

 ## Exercise 6 — AI SDE function

 Design this function:

```
def call_model(...):
    ...
```

 It should support:

```
call_model(
    "Explain RAG",
    model="GPT",
    temperature=0.2,
    max_tokens=500,
    timeout=30,
    retries=3
)
```

 Requirements:

 - `prompt` should be positional.
- `model` should have default `"GPT"`.
- `temperature` should have default `0.7`.
- `max_tokens` should have default `1000`.
- `timeout` and `retries` should be accepted as additional keyword options.
- Print all received values.

 Try to design the function signature **before looking back at the examples above**.

---

 # One mental model to retain

 At this stage, you should have:

```
                    Python name
                        │
                        ↓
                     object
                        │
              ┌─────────┴─────────┐
              ↓                   ↓
           mutable             immutable
              │                   │
        list/dict/set         int/str/tuple
              │
              ↓
        function receives
        another reference
              │
       ┌──────┴──────┐
       ↓             ↓
    mutation      reassignment
       ↓             ↓
 modifies shared   changes local
 object            reference
```

 And for scope:

```
L → Local
E → Enclosing
G → Global
B → Built-in
```

 And for arguments:

```
*args
    ↓
tuple of positional arguments

**kwargs
    ↓
dict of keyword arguments
```

 One last thing: **don't move on until `*args`, `**kwargs`, and LEGB feel mechanically understandable.** These aren't obscure Python trivia—they show up constantly in frameworks, decorators, libraries, test utilities, SDKs, and AI infrastructure.

 Send me your solutions to **Exercises 1–6**. I'll review them line-by-line, including any subtle issues, and then we'll tackle **closures → decorators → generators/iterators**, which is where Python starts becoming considerably more interesting.
