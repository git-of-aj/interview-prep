models = {
    "GPT": {
        "provider": "OpenAI",
        "context": 128000,
        "active": True
    },
    "Claude": {
        "provider": "Anthropic",
        "context": 200000,
        "active": True
    },
    "Gemini": {
        "provider": "Google",
        "context": 1000000,
        "active": False
    }
}

# Add Llama
models["Llama"] = {
    "provider": "Meta",
    "context": 128000,
    "active": True
}

# Activate Gemini
models["Gemini"]["active"] = True

# Provider for GPT
print(models["GPT"]["provider"])

# Active models
print("Active models:")
for model in models:
    if models[model]["active"]:
        print(model)

# Average context
total_context = sum(
    model["context"]
    for model in models.values()
)

average_context = total_context / len(models)

print(f"Average context window: {average_context}")

# Unique providers
unique_providers = {
    model["provider"]
    for model in models.values()
}

print(unique_providers)

# Models with context >= 128000
models_with_large_context = [
    model
    for model in models
    if models[model]["context"] >= 128000
]

print(models_with_large_context)
