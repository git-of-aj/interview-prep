#### Microsoft Agent Framework is the unified successor to Semantic Kernel and AutoGen
a trace represents the complete end-to-end journey of a request through a distributed system, while a span represents a single, timed unit of work within that journey
Trace = Many spans (span + span)
```py
from dotenv import load_dotenv
from microsoft.opentelemetry import use_microsoft_opentelemetry

load_dotenv(override=True)

use_microsoft_opentelemetry(
    enable_azure_monitor=True,
    sampling_ratio=1.0,
    instrumentation_options={
        "langchain": {
            "enabled": True,
            "agent_id": "weather_info_agent_771929",
            "agent_name": "Weather information agent",
        },
    },
)
```
## Tracing
> including LLM calls, tool invocations, and agent decision flows
- Use tracing to debug your AI agents and monitor their behavior in production. Tracing captures detailed telemetry—including latency, exceptions, prompt content, and retrieval operations—so you can identify and fix issues faster.
- Foundry enables it for you automatically once you connect an Application Insights resource to your project.

## Evals
Build in Eval Tool of MS Foundry : 
1. Create a test dataset:  JSONL file with test queries for your agent
```json
{"query": "What's the weather in Seattle?"}
{"query": "Book a flight to Paris"}
{"query": "Tell me a joke"}
```
2. Get The value must match a GPT deployment name in your project — this is the judge model used to score responses.

- Agent evaluators — Evaluate how effectively agents handle tasks, tools, and user intent.
- Quality evaluators — Measure the overall quality of generated responses.
- Text similarity evaluators — Compare generated text against reference answers using NLP metrics.
- Safety evaluators — Identify potential content and security risks in generated output.
- To build your own evaluators, see Custom evaluators.
3. When you run an evaluation, the service sends each test query to your agent, captures the response, and applies your selected evaluators to score the results.
> Evaluation = Test Data + Testing Criteria | An evaluation defines the test data schema and testing criteria

- Offline evaluation tests models in a controlled environment using static datasets, while online evaluation tests models on live production traffic with real users
- `Foundry Evaluator Catalog:`

- Agent Evaluators: Process and system-level evaluators for agent workflows.
- RAG Evaluators: Evaluate end-to-end and retrieval processes in RAG systems.
- Risk and Safety Evaluators: Assess risks and safety concerns in responses.
- General Purpose Evaluators: Quality evaluation such as coherence and fluency.
- OpenAI-Based Graders: Use OpenAI graders including string check, text similarity, score-based grading, and label-based grading.
- Custom Evaluators: Define your own custom evaluators using Python code or LLM-as-a-judge patterns.
