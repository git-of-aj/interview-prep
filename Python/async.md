# `asyncio` in Python — just enough to be useful

 The core idea:

 > **`asyncio` lets one Python program work on multiple things concurrently when those things spend time waiting.**

 It is especially useful for HTTP requests, database calls, sockets, file/network I/O, etc.

 ## 1\. The basic mental model

 Synchronous code:

```
result = download()
process(result)
```

 While `download()` is waiting on the network, your program mostly sits there.

 With `asyncio`, you can say:

```
result = await download()
```

 `await` basically means:

 > "I'm waiting here. While I'm waiting, let other async work run."

 That's the single most important idea.

---

 ## 2\. `async def` and `await`

 An async function looks like this:

```
async def fetch_data():
    result = await download()
    return result
```

 You call it differently from a normal function:

```
result = await fetch_data()
```

 And `await` can only normally be used inside another `async def`.

 So you get a chain:

```
async def main():
    data = await fetch_data()
    print(data)
```

 Then Python needs to start `main()`:

```
import asyncio

asyncio.run(main())
```

 That's the basic skeleton you'll see everywhere:

```
import asyncio

async def main():
    ...

asyncio.run(main())
```

---

 ## 3\. Why bother? Concurrency

 Suppose you need to fetch three URLs.

 Naively:

```
async def main():
    await fetch("url1")
    await fetch("url2")
    await fetch("url3")
```

 That's still basically sequential.

 Instead:

```
async def main():
    results = await asyncio.gather(
        fetch("url1"),
        fetch("url2"),
        fetch("url3"),
    )
```

 Now the three operations can make progress concurrently.

 Conceptually:

```
fetch url1 ── waiting ───────────── done
fetch url2 ───── waiting ───── done
fetch url3 ── waiting ───────── done
             ↑
          asyncio switches
          between them
```

 This is where `asyncio` becomes useful.

---

 ## 4\. `await` does NOT mean "run in parallel"

 This distinction matters.

```
await foo()
```

 means:

 > Run `foo`, and when it reaches an async waiting point, let other tasks run.

 It's **concurrency**, not necessarily parallel CPU execution.

 For example, this is great:

```
async def download():
    await network_request()
```

 because network requests spend lots of time waiting.

 But this:

```
async def calculate():
    for i in range(10_000_000_000):
        ...
```

 doesn't magically become faster because you wrote `async def`.

 For CPU-heavy work, look at multiprocessing / `concurrent.futures` rather than `asyncio`.

---

 ## 5\. Coroutines vs tasks

 This distinction initially feels annoying but is important.

 When you write:

```
fetch("url1")
```

 you get a **coroutine object**. You haven't necessarily scheduled it to run independently.

 You can explicitly create a task:

```
task = asyncio.create_task(fetch("url1"))
```

 Now you've told the event loop:

 > "Schedule this to run."

 Then later:

```
result = await task
```

 A common pattern:

```
async def main():
    task1 = asyncio.create_task(fetch("url1"))
    task2 = asyncio.create_task(fetch("url2"))
    task3 = asyncio.create_task(fetch("url3"))

    result1 = await task1
    result2 = await task2
    result3 = await task3
```

 Or, when you simply want to wait for several operations:

```
results = await asyncio.gather(
    fetch("url1"),
    fetch("url2"),
    fetch("url3"),
)
```

 **Rule of thumb:** use `gather()` when you just want several async operations to finish.

---

 ## 6\. A realistic example

 Imagine three slow operations:

```
import asyncio

async def fetch(name, delay):
    print(f"Starting {name}")
    await asyncio.sleep(delay)
    print(f"Finished {name}")
    return name

async def main():
    results = await asyncio.gather(
        fetch("A", 2),
        fetch("B", 1),
        fetch("C", 3),
    )

    print(results)

asyncio.run(main())
```

 You'll see approximately:

```
Starting A
Starting B
Starting C
Finished B
Finished A
Finished C
['A', 'B', 'C']
```

 The total time is roughly **3 seconds**, not 6.

 Why?

 Because while A is sleeping, B and C get to run.

 `asyncio.sleep()` is a convenient demonstration of what an I/O wait looks like.

---

 ## 7\. The event loop

 You don't need to understand the internals deeply yet.

 Think of the **event loop** as a manager:

```
             Event Loop
           /      |      \
          ↓       ↓       ↓
       Task A   Task B   Task C
          |       |       |
       waiting running waiting
```

 When Task A says:

```
await something()
```

 the event loop can run Task B instead.

 When A's operation is ready, the event loop resumes A.

 That's essentially the magic.

 `asyncio.run(main())` creates/runs the event loop for you.

---

 ## 8\. The big gotcha: blocking code

 This is probably the most important practical thing after `await`.

 Don't do this inside async code:

```
async def main():
    time.sleep(5)
```

 `time.sleep()` blocks the entire thread.

 Instead:

```
async def main():
    await asyncio.sleep(5)
```

 Same idea with libraries.

 If you do:

```
async def main():
    requests.get("https://example.com")
```

 the synchronous `requests` call can block the event loop.

 For async programs, use an async-compatible library, such as an async HTTP client.

---

 ## 9\. Async doesn't automatically make everything faster

 This:

```
async def add(a, b):
    return a + b
```

 doesn't give you any useful concurrency.

 `asyncio` shines when you have:

```
lots of waiting
      ↓
network / database / sockets / APIs
      ↓
asyncio
```

 It is much less useful for:

```
lots of computation
      ↓
CPU-heavy Python code
      ↓
multiprocessing / process pools
```

---

 ## 10\. One pattern worth memorizing

 If you're writing an async application, this pattern will take you surprisingly far:

```
import asyncio

async def work(item):
    # Do asynchronous I/O here
    result = await something(item)
    return result

async def main():
    results = await asyncio.gather(
        work("a"),
        work("b"),
        work("c"),
    )

    print(results)

if __name__ == "__main__":
    asyncio.run(main())
```

 Understand these four things and you know most of the beginner-level `asyncio` you'll actually use:

 1. **`async def`** → defines an async function.
2. **`await`** → wait for async work while allowing other tasks to run.
3. **`asyncio.gather()`** → run/wait for multiple async operations concurrently.
4. **`asyncio.run()`** → starts your async program.

 ### The one sentence to remember

 **`asyncio` is a way for one Python thread to efficiently juggle many tasks that spend their time waiting, with `await` marking the points where another task can get a turn.**
