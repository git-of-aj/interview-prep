"""
GPT     → provider: OpenAI, context: 128000, active: True
Claude  → provider: Anthropic, context: 200000, active: True
Gemini  → provider: Google, context: 1000000, active: False

"""

models = {
    "GPT": {
        "provider": "OpenAI",
        "context": 128000,
        "active": True

    },
    "Claude": {
        "provider": "Anthropic",
        "context":200000 ,
        "active": True

    },
    "Gemini": {
        "provider": "Google" ,
        "context": 1000000,
        "active": False

    }
}

print(models["GPT"]["provider"]) # works

print("List of Active Models")
for model in models.keys():
    if models[model]["active"] == True:
        print(model)

models["Llama"] = {
            "provider": "Meta" ,
            "context": 128000,
            "active": True
}

print(models)

# Average context window
sum = 0
for model in models.keys():
    sum += models[model]["context"] 
average_context = sum / len(models.keys())
print(f"average context window is {average_context}")

unique_providers = set(models.keys())
print(unique_providers)

list_of_models = []
for model in models.keys():
    if models[model]["context"] >= 128000:
        list_of_models.append(model)
print(list_of_models)

# for provider, _ in models.items():
#         print(provider,_)  ==> produces string
#         print(type(provider))
